# Base class for application-specific activities handlers.
#
# Subclass this and implement #handle to react to ActiveSupport::Notifications
# and create Oscar::Activities::Activity records if desired.
#
# == Overview
#
# ApplicationActivity provides a framework for tracking application events and rendering
# them using ViewComponents. Each subclass represents a specific type of activity
# (e.g., user login, document creation, comment posted) and is responsible for:
#
# 1. Subscribing to ActiveSupport::Notifications events via the +tracks+ DSL
# 2. Extracting relevant data from event payloads in the +handle+ method
# 3. Specifying a ViewComponent for rendering via the +render_with+ DSL
#
# == Configuring View Components
#
# Each ApplicationActivity subclass can specify a custom ViewComponent to control
# how it is displayed in the UI. The component is resolved using three strategies,
# in the following priority order:
#
# === 1. Explicit Declaration (Highest Priority)
#
# Use the +render_with+ DSL method to explicitly declare the component class:
#
#   class UserLoginActivity < Oscar::Activities::ApplicationActivity
#     render_with UserLoginComponent  # Explicit declaration
#
#     tracks "user.login"
#
#     # Store activity-specific data
#     attribute :user_id, :integer
#     attribute :ip_address, :string
#
#     def handle(event_name, started_at, finished_at, event_id, payload)
#       self.user_id = payload[:user_id]
#       self.ip_address = payload[:ip_address]
#       self.actor = payload[:actor]
#       self.target = payload[:target]
#     end
#   end
#
#   # The corresponding component
#   class UserLoginComponent < ViewComponent::Base
#     def initialize(application_activity:, actor:, **other_args)
#       @application_activity = application_activity
#       @actor = actor
#     end
#
#     def call
#       content_tag :div, class: "activity-item" do
#         if @actor == @application_activity.actor
#           "You logged in from #{@application_activity.ip_address}"
#         else
#           "#{@application_activity.actor.name} logged in from #{@application_activity.ip_address}"
#         end
#       end
#     end
#   end
#
# === 2. Naming Convention (Implicit)
#
# If +render_with+ is not used, the system automatically looks for a component
# following the naming convention: replace "Activity" with "Component" in the
# activity class name.
#
#   # Activity class
#   class DocumentCreated< Oscar::Activities::ApplicationActivity
#     # No render_with declaration needed
#     tracks "document.created"
#   end
#
#   # Component will be automatically resolved to:
#   # DocumentCreatedComponent (if it exists)
#
# For namespaced activities, the namespace is preserved:
#
#   # Activity: NameSpace::Admin::UserBanned
#   # Resolves to: NameSpace::Admin::UserBannedComponent
#
# === 3. Fallback Component (Default)
#
# If neither explicit declaration nor naming convention resolves to an existing
# component, the system uses Oscar::Activities::FallbackComponent, which displays
# a placeholder message prompting you to add a proper component.
#
# === Component Structure
#
# All components must accept two required keyword arguments:
# - +application_activity:+ - The activity instance being rendered
# - +actor:+ - The current user/actor viewing the timeline
#
# Components may also accept additional optional arguments via +**other_args+:
#
#   class UserLoginComponent < ViewComponent::Base
#     def initialize(application_activity:, actor:, **other_args)
#       @application_activity = application_activity
#       @actor = actor
#     end
#
#     def call
#       content_tag :div, class: "activity-item" do
#         if @actor == @application_activity.actor
#           "You logged in from #{@application_activity.ip_address}"
#         else
#           "User #{@application_activity.actor.name} logged in from #{@application_activity.ip_address}"
#         end
#       end
#     end
#   end
#
# The +actor:+ parameter allows components to customize rendering based on who is
# viewing the timeline (e.g., showing "You" vs. the user's name, hiding sensitive
# information, or highlighting relevant activities).
#
# === Best Practices
#
# - Use naming convention for straightforward cases to reduce boilerplate
# - Use +render_with+ when you need to share a component across multiple activity types
# - Use +render_with+ when the component name doesn't follow the standard convention
#
#   # Example: Sharing a component
#   class UserCreatedActivity < Oscar::Activities::ApplicationActivity
#     render_with UserChangeComponent  # Shared with UserUpdatedActivity
#   end
#
#   class UserUpdatedActivity < Oscar::Activities::ApplicationActivity
#     render_with UserChangeComponent  # Same component, different activity
#   end
#
# == Event Tracking
#
# Use the +tracks+ DSL method to subscribe to ActiveSupport::Notifications events:
#
#   tracks "document.created"
#   tracks "comment.posted"
#
# When the event fires, the +handle+ method is called with the event details.
#
# == Example: Complete Activity Implementation
#
#   class DocumentCreated < Oscar::Activities::ApplicationActivity
#     # Specify the component for rendering this activity type
#     render_with DocumentCreatedComponent
#
#     # Subscribe to the event
#     tracks "document.created"
#
#     # Extract data from the event payload
#     def handle(event_name, started_at, finished_at, event_id, payload)
#       self.document_id = payload[:document_id]
#       self.document_title = payload[:document_title]
#       self.target_event = "created"
#     end
#
#     # Optional: Filter which events to handle
#     def self.perform_handle?(event_name, started_at, finished_at, instrumenter_id, payload)
#       # Only track documents with title
#       payload[:document_title].present?
#     end
#   end

module Oscar
  module Activities
    class ApplicationActivity < ApplicationRecord
      self.abstract_class = true

      # The ViewComponent class used to render this activity type in the UI.
      # Set this using the +render_with+ DSL method in subclasses.
      # Defaults to nil, which triggers fallback rendering.
      class_attribute :component_class, instance_accessor: false, default: nil


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
        # Declares the ViewComponent class to use for rendering this activity type.
        #
        # @param klass [Class] A ViewComponent class that accepts
        # * an +application_activity:+ keyword argument
        # * an +actor:+ keyword argument
        # @example
        #   class CommentPostedActivity < Oscar::Activities::ApplicationActivity
        #     render_with CommentPostedComponent
        #   end
        def render_with(klass)
          self.component_class = klass
        end
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

      def component(actor: , **other_args)
        activity.component(actor: actor, **other_args)
      end

    end
  end
end
