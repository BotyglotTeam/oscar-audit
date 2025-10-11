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

      included do
        # keep a per-class registry of subscribers to prevent duplicate subscriptions
        class_attribute :_audit_log_subscribers, instance_accessor: false, default: {}
      end

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

          # Avoid double-subscriptions in reloader/development by tracking by event
          return if _audit_log_subscribers.key?(event)

          resolver = build_handler_resolver(handler, block)

          subscriber = ActiveSupport::Notifications.subscribe(event) do |name, start, finish, id, payload|
            instance = resolver.call(name, start, finish, id, payload)
            unless instance.respond_to?(:handle)
              raise NoMethodError, "Resolved audit log handler for '#{event}' does not implement #handle"
            end
            instance.handle(name, start, finish, id, payload)
          end

          # store reference for potential future unsubscription, keyed by event
          self._audit_log_subscribers = _audit_log_subscribers.merge(event => subscriber)
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
      end
    end
  end
end
