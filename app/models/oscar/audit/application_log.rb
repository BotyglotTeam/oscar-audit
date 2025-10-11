# Base class for application-specific audit log handlers.
#
# Subclass this and implement #handle to react to ActiveSupport::Notifications
# and create Oscar::Audit::Log records if desired.

module Oscar
  module Audit
    class ApplicationLog < ApplicationRecord
      self.abstract_class = true

      has_one :log,
              as: :application_log,
              class_name: "Oscar::Audit::Log",
              inverse_of: :application_log

      # Handle notification from ActiveSupport::Notifications for this application log.
      #
      # @param event_name [String] name of the event (e.g., 'render', 'sql.active_record')
      # @param started_at [Time] when the instrumented block started execution
      # @param finished_at [Time] when the instrumented block ended execution
      # @param event_id [String] unique ID for the instrumenter that fired the event
      # @param payload [Hash] arbitrary event payload
      def handle(event_name, started_at, finished_at, event_id, payload)
        raise NotImplementedError.new("You must implement handle in your application audit log")
      end

      def create_associated_log
        create_log!
      end

    end
  end
end
