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
        def audit_log(event_name, handler = nil, &block)
          event = event_name.to_s

          # Compute a key that uniquely identifies this handler for this event,
          # so we can avoid duplicate subscriptions for the same handler while
          # still allowing multiple handlers per event.
          handler_key = handler_key_for(handler, block)

          # Skip only if this exact handler is already subscribed for this event
          return if Oscar::Audit.subscribed_to_event?(event, handler_key)

          resolver = build_handler_resolver(handler, block)

          subscriber = ActiveSupport::Notifications.subscribe(event) do |name, start, finish, id, payload|
            # Respect global/thread-local application log toggle
            next unless Oscar::Audit.application_logs_enabled?

            instance = resolver.call(name, start, finish, id, payload)
            unless instance.respond_to?(:handle)
              raise NoMethodError, "Resolved audit log handler for '#{event}' does not implement #handle"
            end
            instance.handle(name, start, finish, id, payload)
          end

          # store reference globally for potential future unsubscription, keyed by event and handler
          Oscar::Audit.register_subscriber(event, handler_key, subscriber)
        end

        private

        def build_handler_resolver(handler, block)
          if block
            # Caller decides how to create/resolve the handler instance per-notification
            return block
          end

          case handler
          when Class
            klass = handler
            unless klass <= Oscar::Audit::ApplicationLog
              raise ArgumentError, "#{klass} must inherit from Oscar::Audit::ApplicationLog"
            end
            return ->(_name, _start, _finish, _id, _payload) { klass.new }
          when String, Symbol
            const_name = handler.to_s
            return lambda { |_name, _start, _finish, _id, _payload|
              klass = const_name.constantize
              unless klass <= Oscar::Audit::ApplicationLog
                raise ArgumentError, "#{klass} must inherit from Oscar::Audit::ApplicationLog"
              end
              klass.new
            }
          when nil
            raise ArgumentError, "You must provide a handler class or a block to audit_log"
          else
            raise ArgumentError, "Unsupported handler: #{handler.inspect}"
          end
        end

        def handler_key_for(handler, block)
          if block
            "block:#{block.object_id}"
          elsif handler.is_a?(Class)
            "class:#{handler.name}"
          elsif handler.is_a?(String) || handler.is_a?(Symbol)
            "const:#{handler.to_s}"
          else
            'unknown'
          end
        end
      end
    end
  end
end
