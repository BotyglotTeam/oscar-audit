# Base class for application-specific activities handlers.
#
# Subclass this and implement #handle to react to ActiveSupport::Notifications
# and create Oscar::Activities::Activity records if desired.

module Oscar
  module Activities
    class ApplicationActivity < ApplicationRecord
      self.abstract_class = true

      after_create_commit :create_associated_activity

      has_one :activity,
              as: :application_activity,
              class_name: "Oscar::Activities::Activity",
              inverse_of: :application_activity

      attr_accessor :actor
      attr_accessor :impersonated_by
      attr_accessor :target
      attr_accessor :target_event

      class << self
        # Declare that this ApplicationActivity subclass tracks a specific ActiveSupport::Notifications event.
        # event_name must be a String. Regexp and other types are not allowed.
        def tracks(event_name)
          unless event_name.is_a?(String)
            raise ArgumentError, "event_name must be a String"
          end

          # Prevent duplicate subscriptions per subclass per event
          @__tracked_events ||= {}
          return if @__tracked_events.key?(event_name)

          subscriber = ActiveSupport::Notifications.subscribe(event_name) do |ev_name, started_at, finished_at, event_id, payload|
            next unless Oscar::Activities.application_activities_enabled?
            self.handle(ev_name, started_at, finished_at, event_id, payload)
          end

          @__tracked_events[event_name] = subscriber
          Oscar::Activities.register_event_handler_subscriber(event_name, name, subscriber)
        end

        def handle(event_name, started_at, finished_at, instrumenter_id, payload)
          return unless perform_handle?(event_name, started_at, finished_at, instrumenter_id, payload)
          instance = new
          instance.handle(event_name, started_at, finished_at, instrumenter_id, payload)
          instance.save!
        end

        # Should this event be handled (i.e., should an ApplicationActivity record be created)?
        # Subclasses can override this to implement de-duplication or filtering logic.
        # By default we perform handling.
        def perform_handle?(event_name, started_at, finished_at, instrumenter_id, payload)
          true
        end
      end

      # @param event_name [String] name of the event (e.g., 'render', 'sql.active_record')
      # @param started_at [Time] when the instrumented block started execution
      # @param finished_at [Time] when the instrumented block ended execution
      # @param instrumenter_id [String] unique ID for the instrumenter that fired the event
      # @param payload [Hash] arbitrary event payload
      def handle(event_name, started_at, finished_at, event_id, payload)
        # Implement in subclass
        # extract relevant data from payload and create a activity record
        # also extract target, actor and impersonated_by and pass them to the activity record
        raise NotImplementedError.new("You must implement handle in your application activity child class")
      end

      def create_associated_activity
        create_activity!(
          target: target,
          target_event: target_event,
          actor: actor,
          impersonated_by: impersonated_by,
          created_at: created_at,
          updated_at: updated_at,
        )
      end

      # Make records readonly after they have been persisted
      def readonly?
        persisted?
      end

    end
  end
end
