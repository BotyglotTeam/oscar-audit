module Oscar
  module Activities
    # Component for rendering a timeline of activities.
    #
    # TimelineComponent displays a chronological list of activities, rendering each
    # activity using its configured ViewComponent (via explicit +render_with+,
    # naming convention, or fallback).
    #
    # == Usage
    #
    # In your controller:
    #
    #   @activities = ...
    #
    # In your view:
    #
    #   <%= render Oscar::Activities::TimelineComponent.new(
    #         activities: @activities,
    #         current_actor: current_user
    #       ) %>
    #
    # == Component Resolution
    #
    # For each activity, the timeline resolves the component to render:
    #
    # 1. If the activity is missing its application_activity association (orphaned),
    #    render Oscar::Activities::ApplicationActivityMissingComponent
    # 2. Check if the activity's ApplicationActivity subclass declares a component
    #    via +render_with+ (explicit)
    # 3. Try to find a component using naming convention (implicit)
    # 4. Fall back to Oscar::Activities::FallbackComponent
    #
    # == Customization
    #
    # You can customize the timeline appearance by:
    #
    # - Overriding the template (timeline_component.html.erb)
    # - Passing custom CSS classes via slots (if implemented)
    # - Subclassing TimelineComponent for project-specific behavior
    #
    # == Example with Filtering
    #
    #   <%= render Oscar::Activities::TimelineComponent.new(
    #         activities: @activities.where(actor: current_user),
    #         current_actor: current_user
    #       ) %>
    class TimelineComponent < ViewComponent::Base
      # @param activities [ActiveRecord::Relation<Oscar::Activities::Activity>] Collection of activities to display
      # @param current_actor [Object] The current user/actor viewing the timeline (for permission checks, highlighting, etc.)
      def initialize(activities:, current_actor:)
        @activities = activities
        @current_actor = current_actor
      end

      private

      attr_reader :activities, :current_actor

      # Renders a single activity using its resolved component.
      def render_activity(activity:, actor:)
        render activity.component(actor: actor)
      end

      def activities?
        activities.any?
      end
    end
  end
end