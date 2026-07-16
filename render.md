## Rendering Activities

### Basic Usage

```erb
<%= render Oscar::Activities::TimelineComponent.new(
      activities: @activities,
      current_actor: current_user
    ) %>
```

### Component Resolution

Activities are rendered using ViewComponents resolved in this order:

1. **Missing** - If `application_activity` is nil (orphaned/deleted), uses `Oscar::Activities::ApplicationActivityMissingComponent` (displays: "Activity #123 is missing its associated application activity data")
2. **Explicit** - `render_with YourComponent` in the ApplicationActivity subclass
3. **Convention** - `DocumentCreated` → `DocumentCreatedComponent`
4. **Fallback** - If component not found, uses `Oscar::Activities::FallbackComponent` (displays: "Please add the component to render activities of type DocumentCreated")

### Creating Components

Components receive `application_activity:` and `actor:` parameters:

```ruby
class DocumentCreatedComponent < ViewComponent::Base
  def initialize(application_activity:, actor:, **)
    @activity = application_activity
    @actor = actor
  end

  def call
    tag.div(class: "activity-item") do
      "#{actor_name} created #{@activity.document_title}"
    end
  end

  private

  def actor_name
    @actor == @activity.actor ? "You" : @activity.actor.name
  end
end
```

Use the `actor` parameter to personalize rendering ("You" vs user name, hide sensitive data, etc.).

### Configuration Options

**Naming Convention** (default)
```ruby
class DocumentCreated < Oscar::Activities::ApplicationActivity
  tracks "document.created"
end

# Automatically uses DocumentCreatedComponent
```

**Explicit Declaration** (for shared components or custom names)
```ruby
class UserCreated < Oscar::Activities::ApplicationActivity
  render_with UserChangeComponent
end

class UserUpdated < Oscar::Activities::ApplicationActivity
  render_with UserChangeComponent  # Shared component
end
```