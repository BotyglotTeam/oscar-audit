# Abstract class from which all commands inherit from.
#
# **Invoking a command**
#
# In order to invoke a command you only need to create into the database. Upon creation the command
# will create a {Commands::Runner} instance, and it will pass it arguments about how the command should be run.
#
# The following virtual attributes are forwarded to the {Commands::Runner}
#
#  * `async` => see {Commands::Runner#async}
#  * `async_options` => see {Commands::Runner#async_options}
#  * `force` => see {Commands::Runner#force}
#  * `run_automatically` => see {Commands::Runner#run_automatically}
#  * `triggered_by` => see {Commands::Runner#triggered_by}
#

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
      # @param name [String] name of the event (e.g., 'render', 'sql.active_record')
      # @param started [Time] when the instrumented block started execution
      # @param finished [Time] when the instrumented block ended execution
      # @param unique_id [String] unique ID for the instrumenter that fired the event
      # @param payload [Hash] arbitrary event payload
      def handle(name, started, finished, unique_id, payload)
        raise NotImplementedError.new("You must implement handle in your application audit log")
      end

      def create_associated_log
        create_log!
      end

    end
  end
end
