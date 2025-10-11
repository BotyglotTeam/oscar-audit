require "oscar/audit/version"
require "oscar/audit/engine"
require "oscar/audit/railtie"

module Oscar
  module Audit
    # Application logs are enabled by default in all environments.
    # This toggle is thread-local and can be overridden within a block using
    # with_application_logs / without_application_logs.

    KEY = :__oscar_audit_application_logs_enabled
    # SUBSCRIBERS is a Hash of event => { handler_key => subscriber }
    SUBSCRIBERS = Hash.new { |h, k| h[k] = {} }

    class << self
      def application_logs_enabled?
        val = Thread.current[KEY]
        if val.nil?
          if defined?(Rails) && Rails.respond_to?(:env) && Rails.env.test?
            false
          else
            true
          end
        else
          !!val
        end
      end

      def with_application_logs
        prev = application_logs_enabled?
        Thread.current[KEY] = true
        yield
      ensure
        Thread.current[KEY] = prev
      end

      def without_application_logs
        prev = application_logs_enabled?
        Thread.current[KEY] = false
        yield
      ensure
        Thread.current[KEY] = prev
      end

      # Optional imperative API
      def enable_application_logs!
        Thread.current[KEY] = true
      end

      def disable_application_logs!
        Thread.current[KEY] = false
      end

      # Global subscription registry helpers (used to avoid duplicate subscriptions in test/reload scenarios)
      def subscribed_to_event?(event, key = nil)
        if key
          SUBSCRIBERS.dig(event, key) ? true : false
        else
          SUBSCRIBERS.key?(event) && SUBSCRIBERS[event].any?
        end
      end

      def register_subscriber(event, key, subscriber)
        SUBSCRIBERS[event][key] = subscriber
      end
    end
  end
end
