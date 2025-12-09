module Oscar
  module Activities
    # Component for rendering activities that are missing their associated application_activity.
    #
    # This component is used by TimelineComponent when an Oscar::Activities::Activity record
    # exists but its polymorphic +application_activity+ association is nil.
    #
    # == When This Occurs
    #
    # This situation can happen when:
    #
    # 1. The associated ApplicationActivity record was deleted (orphaned Activity)
    # 2. Data was corrupted or improperly migrated
    # 3. An Activity was created manually without an application_activity
    #
    # == Purpose
    #
    # Rather than causing errors or skipping the activity entirely, this component
    # provides a graceful fallback that:
    # - Alerts developers/administrators to the issue
    # - Shows the Activity's basic metadata (ID, timestamps)
    # - Maintains timeline continuity
    #
    # == Example Output
    #
    # "Activity #123 is missing its associated application activity data (created at June 15, 2024)"
    #
    # == Resolution
    #
    # If you see this component in production:
    # - Investigate why the application_activity association is missing
    # - Consider cleaning up orphaned Activity records
    # - Check for database integrity issues
    # - Review your activity deletion/cleanup policies
    class ApplicationActivityMissingComponent < ViewComponent::Base
      # @param activity [Oscar::Activities::Activity] The activity record missing its application_activity
      # @param actor [Object] The current user/actor viewing the timeline
      def initialize(activity:, actor:)
        @activity = activity
        @actor = actor
      end

      def call
        content_tag :div, class: "activity-missing-data" do
          concat content_tag(:strong, "Activity ##{@activity.id}")
          concat " is missing its associated application activity data "
          concat content_tag(:span, "(created #{time_ago_in_words(@activity.created_at)} ago)", class: "text-muted")
        end
      end

      private

      attr_reader :activity, :actor
    end
  end
end
