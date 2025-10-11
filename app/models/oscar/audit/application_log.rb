# Base class for application-specific audit log handlers.
#
# Subclass this and implement #handle to react to ActiveSupport::Notifications
# and create Oscar::Audit::Log records if desired.

module Oscar
  module Audit
    class ApplicationLog < ApplicationRecord
      self.abstract_class = true

      after_create_commit :create_associated_log

      has_one :log,
              as: :application_log,
              class_name: "Oscar::Audit::Log",
              inverse_of: :application_log

      attr_accessor :actor
      attr_accessor :impersonated_by
      attr_accessor :target
      attr_accessor :target_event

      class << self
        # Declare that this ApplicationLog subclass tracks a specific ActiveSupport::Notifications event.
        # event_name must be a String. Regexp and other types are not allowed.
        def tracks(event_name)
          unless event_name.is_a?(String)
            raise ArgumentError, "event_name must be a String"
          end

          # Prevent duplicate subscriptions per subclass per event
          @__tracked_events ||= {}
          return if @__tracked_events.key?(event_name)

          subscriber = ActiveSupport::Notifications.subscribe(event_name) do |ev_name, started_at, finished_at, event_id, payload|
            next unless Oscar::Audit.application_logs_enabled?
            self.handle(ev_name, started_at, finished_at, event_id, payload)
          end

          @__tracked_events[event_name] = subscriber
          Oscar::Audit.register_event_handler_subscriber(event_name, name, subscriber)
        end

        def handle(event_name, started_at, finished_at, event_id, payload)
          instance = new
          instance.handle(event_name, started_at, finished_at, event_id, payload)
          instance.save!
        end
      end

      # @param event_name [String] name of the event (e.g., 'render', 'sql.active_record')
      # @param started_at [Time] when the instrumented block started execution
      # @param finished_at [Time] when the instrumented block ended execution
      # @param event_id [String] unique ID for the instrumenter that fired the event
      # @param payload [Hash] arbitrary event payload
      def handle(event_name, started_at, finished_at, event_id, payload)
        # Implement in subclass
        # extract relevant data from payload and create a log record
        # also extract target, actor and impersonated_by and pass them to the log record
        raise NotImplementedError.new("You must implement handle in your application audit log")
      end

      def create_associated_log
        create_log!(
          target: target,
          target_event: target_event,
          actor: actor,
          impersonated_by: impersonated_by,
          created_at: created_at,
          updated_at: updated_at,
        )
      end

    end
  end
end
