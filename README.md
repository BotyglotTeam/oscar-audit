# Oscar::Audit
Short description and motivation.

## Usage

Application logs are enabled by default. You can temporarily enable/disable them in a thread-local, block-scoped way, or imperatively for all threads.

- Default behavior: application logs are enabled by default.
- Scope: block helpers are thread-local. They restore the previous state after the block finishes (even if it raises).
- Imperative methods are global: they change the setting for all threads until changed again.

Block helpers:

```ruby
# Force-enable within the block (restores previous state after)
Oscar::Audit.with_application_logs do
  # application logs are ON here
end

# Force-disable within the block (restores previous state after)
Oscar::Audit.without_application_logs do
  # application logs are OFF here
end
```

Imperative API (current thread only):

```ruby
Oscar::Audit.disable_application_logs!
# application logs are OFF for the current thread until changed again

Oscar::Audit.enable_application_logs!
# application logs are ON for the current thread until changed again
```

Nesting examples:

```ruby
Oscar::Audit.without_application_logs do
  # OFF here
  Oscar::Audit.with_application_logs do
    # ON here (temporarily overrides the outer scope)
  end
  # back to OFF here
end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem "oscar-audit", git: "https://github.com/BotyglotTeam/oscar-audit", branch: "main"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install oscar-audit
```

## Migrations

This engine ships with database migrations. To install them into your host app and run them,

  ```bash
  bin/rails oscar_audit:install:migrations
  ```


## Testing

### Regenerating the dummy app

```bash
rm -rf spec/dummy
cd ../ 
rails new oscar-audit/spec/dummy --skip-active-storage --skip-action-mailer --skip-action-cable --skip-javascript --skip-sprockets --skip-test --database=sqlite3 --skip-kamal --skip-git
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


