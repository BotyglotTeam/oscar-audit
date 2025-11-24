require "oscar/activities/version"
require "oscar/activities/engine"
require "oscar/activities/railtie"

module Oscar
  module Activities
    # Application logs are enabled by default in all environments (except test).
    # This toggle is thread-local and can be overridden within a block using
    # with_application_logs / without_application_logs.

    APPLICATION_LOGS_TOGGLE_KEY = :__oscar_activities_application_logs_enabled
    # EVENT_SUBSCRIBERS is a Hash of event_name => { handler_dedup_key => subscriber }
    EVENT_SUBSCRIBERS = Hash.new { |h, k| h[k] = {} }

    class << self
      # Global flag that applies across all threads. Thread-local overrides take precedence.
      @global_application_logs_enabled = true

      def application_logs_enabled?
        thread_value = Thread.current[APPLICATION_LOGS_TOGGLE_KEY]
        return !!thread_value unless thread_value.nil?
        !!@global_application_logs_enabled
      end

      def with_application_logs
        previous_state = application_logs_enabled?
        Thread.current[APPLICATION_LOGS_TOGGLE_KEY] = true
        yield
      ensure
        Thread.current[APPLICATION_LOGS_TOGGLE_KEY] = previous_state
      end

      def without_application_logs
        previous_state = application_logs_enabled?
        Thread.current[APPLICATION_LOGS_TOGGLE_KEY] = false
        yield
      ensure
        Thread.current[APPLICATION_LOGS_TOGGLE_KEY] = previous_state
      end

      # Optional imperative API (global across all threads)
      def enable_application_logs!
        @global_application_logs_enabled = true
      end

      def disable_application_logs!
        @global_application_logs_enabled = false
      end

      # Global subscription registry helpers (used to avoid duplicate subscriptions in test/reload scenarios)
      def handler_subscribed_for_event?(event_name, handler)
        EVENT_SUBSCRIBERS.dig(event_name, handler) ? true : false
      end

      def register_event_handler_subscriber(event_name, handler, subscriber)
        EVENT_SUBSCRIBERS[event_name][handler] = subscriber
      end
    end
  end
end
