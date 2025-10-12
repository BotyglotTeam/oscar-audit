# Oscar::Audit

A small Rails engine for recording an audit trail across your application.
It captures who did what to which record and when, and ties each audit entry
back to a domain-specific "application log" record that you control.

Core ideas:
- An audit Log stores: actor (who), optional impersonated_by, target (what),
  target_event (what happened), and a reference to your application_log record.
- actor, impersonated_by and target are polymorphic, so you can attach any model
  (e.g., User, Admin, Document, etc.).
- Application logs are enabled by default, can be toggled on/off per-thread in a block,
  or globally across the process.


## Installation
Add to your Gemfile and bundle:

```ruby
gem "oscar-audit", git: "https://github.com/BotyglotTeam/oscar-audit", branch: "main"
```

```bash
bundle
```

Install and run the engine migrations (creates the oscar_audit_logs table):

```bash
bin/rails oscar_audit:install:migrations
bin/rails db:migrate
```

You will also create tables for your own ApplicationLog subclasses (see below).


## Defining an application log
To capture events from your app, define a model that inherits from
Oscar::Audit::ApplicationLog. This model persists your app-specific details and,
after it is created, automatically creates the associated audit Log.

1) Create a table for your application log (you can add any fields you need):

```ruby
# db/migrate/2025xxxxxx_create_document_view_logs.rb
class CreateDocumentViewLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :document_view_logs do |t|
      t.string :note
      t.timestamps
    end
  end
end
```

2) Define the model, subscribe to an event, and map payload to the audit fields:

```ruby
# app/models/document_view_log.rb
class DocumentViewLog < Oscar::Audit::ApplicationLog
  # Subscribe once to an ActiveSupport::Notifications event
  tracks "audit.document.viewed"

  # Called whenever the event fires
  def handle(event_name, started_at, finished_at, instrumenter_id, payload)
    self.actor           = payload[:actor]             # e.g., current_user
    self.impersonated_by = payload[:impersonated_by]   # optional
    self.target          = payload[:target]            # e.g., a Document
    self.target_event    = "viewed"                    # a short, app-defined label
    self                  # return self so it will be saved
  end
end
```

3) Emit the event from your application code:

```ruby
ActiveSupport::Notifications.instrument(
  "audit.document.viewed",
  actor: current_user,
  target: document,
  impersonated_by: current_admin_if_impersonating
)
```

When the event is instrumented, a DocumentViewLog record is saved and an
Oscar::Audit::Log entry is automatically created and linked to it.

Tip: You can also create your application log directly if you are not using
ActiveSupport::Notifications for a particular case:

```ruby
DocumentViewLog.create!(actor: current_user, target: document, target_event: "viewed")
# The associated Oscar::Audit::Log is created after commit.
```


## Toggling audit processing
Application logs are ON by default. You can toggle them in a thread-safe way,
or globally:

- Thread-local, block-scoped helpers (previous state is restored at block end):

```ruby
Oscar::Audit.with_application_logs do
  # ON inside this block (regardless of previous state)
end

Oscar::Audit.without_application_logs do
  # OFF inside this block
end
```

- Global imperative API (applies across all threads until changed again):

```ruby
Oscar::Audit.disable_application_logs!
Oscar::Audit.enable_application_logs!
```

Nesting works as expected (inner block overrides the outer state temporarily).


## Querying audit logs
Audit entries are stored in Oscar::Audit::Log. Some examples:

```ruby
# Most recent actions on a record
Oscar::Audit::Log.where(target: document).order(created_at: :desc)

# Actions performed by a user
Oscar::Audit::Log.where(actor: user)

# Actions of a certain type
Oscar::Audit::Log.where(target_event: "viewed")
```


## Immutability
For safety, persisted records are readonly:
- Oscar::Audit::ApplicationLog instances cannot be updated or destroyed after create.
- Oscar::Audit::Log entries cannot be updated or destroyed after create.

If you need to change data, create a new record that reflects the new state.


## Notes
- tracks expects a String event name (e.g., "audit.something.happened").
- You can override .perform_handle?(...) on your ApplicationLog subclass to
  skip creating a record (e.g., deduplicate by an ID in the payload).


## Contributing
Bug reports and pull requests are welcome.

## License
The gem is available as open source under the terms of the MIT License.


