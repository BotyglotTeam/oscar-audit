module Oscar
  module Activities
    # Default fallback component for rendering activities without a custom component.
    #
    # This component is automatically used when an ApplicationActivity subclass
    # does not specify a custom ViewComponent via the +render_with+ DSL.
    #
    # == Purpose
    #
    # FallbackComponent serves as a placeholder during development to alert developers
    # that a specific activity type does not have a dedicated rendering component.
    # This helps ensure that all activity types have proper UI representations in production.
    #
    # == When It's Used
    #
    # If you create an activity handler like this:
    #
    #   class UserLoginActivity < Oscar::Activities::ApplicationActivity
    #     tracks "user.login"
    #     # No render_with declaration
    #   end
    #
    # The system will use FallbackComponent to render UserLoginActivity instances,
    # displaying: "Please add the component to render activities of type UserLoginActivity"
    #
    # == How to Fix
    #
    # Create a custom component and declare it in your activity class:
    #
    #   class UserLoginActivity < Oscar::Activities::ApplicationActivity
    #     render_with UserLoginComponent  # Add this line
    #     tracks "user.login"
    #   end
    #
    #   class UserLoginComponent < ViewComponent::Base
    #     def initialize(application_activity:)
    #       @activity = application_activity
    #     end
    #
    #     def call
    #       content_tag :div, "User logged in at #{@activity.created_at}"
    #     end
    #   end
    class FallbackComponent < ViewComponent::Base
      def initialize(application_activity:)
        @application_activity = application_activity
      end

      def call
        content_tag :div, "Please add the component to render activities of type #{@application_activity.class.name}"
      end
    end
  end
end
