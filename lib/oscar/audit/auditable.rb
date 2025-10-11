# lib/oscar/audit/auditable.rb
# Provides a simple DSL to bind application log handlers to ActiveSupport notifications
# Usage inside any ActiveRecord model:
#   class Project < ApplicationRecord
#     audit_log 'my.event', 'Project::MyEvent'
#   end
# Where Project::MyEvent is a subclass of Oscar::Audit::ApplicationLog and implements #handle.

module Oscar
  module Audit
    module Auditable
      extend ActiveSupport::Concern

      class_methods do
        # Declares an audit log handler for a given ActiveSupport::Notifications event.
        #
        # event_name - String/Symbol event name (e.g., 'render', 'sql.active_record').
        # handler - Class or String/Symbol constant name that resolves to a subclass of
        #           Oscar::Audit::ApplicationLog. If a block is provided, it must return
        #           the handler instance to be used for processing the event.
        #
        # The handler's #handle(name, start, finish, id, payload) instance method will be invoked.
        #
        # Requirements simplified:
        # - handler is mandatory and must be a String name of an Oscar::Audit::ApplicationLog subclass.
        # - event_name can be a String or a Regexp (as supported by ActiveSupport::Notifications.subscribe).
        def audit_log(event_name, handler)
          event_registry_key = event_name.is_a?(Regexp) ? event_name.inspect : event_name.to_s

          # Skip only if this exact handler is already subscribed for this event
          return if Oscar::Audit.handler_subscribed_for_event?(event_registry_key, handler)

          handler_instance_resolver = build_handler_resolver(handler)

          notification_subscriber = ActiveSupport::Notifications.subscribe(event_name) do |ev_name, started_at, finished_at, event_id, payload|
            # Respect global/thread-local application log toggle
            next unless Oscar::Audit.application_logs_enabled?

            handler_instance = handler_instance_resolver.call(ev_name, started_at, finished_at, event_id, payload)

            unless handler_instance.respond_to?(:handle)
              raise NoMethodError, "Resolved audit log handler for '#{event_registry_key}' does not implement #handle"
            end

            handler_instance.handle(ev_name, started_at, finished_at, event_id, payload)
          end

          # store reference globally for potential future unsubscription, keyed by event and handler
          Oscar::Audit.register_event_handler_subscriber(event_registry_key, handler, notification_subscriber)
        end

        private

        def build_handler_resolver(handler)
          unless handler.is_a?(String)
            raise ArgumentError, "handler must be the full String name of an Oscar::Audit::ApplicationLog subclass"
          end

          return lambda { |_event_name, _started_at, _finished_at, _event_id, _payload|
            klass = handler.constantize
            unless klass <= Oscar::Audit::ApplicationLog
              raise ArgumentError, "#{klass} must inherit from Oscar::Audit::ApplicationLog"
            end
            klass.new
          }
        end
      end
    end
  end
end
