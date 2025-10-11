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

      # name    # => String, name of the event (such as 'render' from above)
      # start   # => Time, when the instrumented block started execution
      # finish  # => Time, when the instrumented block ended execution
      # id      # => String, unique ID for the instrumenter that fired the event
      # payload # => Hash, the payload
      def handle(name, started, finished, unique_id, payload)
        raise NotImplementedError.new("You must implement handle in your application audit log")
      end

      def create_associated_log
        create_log!
      end

    end
  end
end
