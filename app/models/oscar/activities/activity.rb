# app/models/oscar/activities/log.rb
module Oscar
  module Activities
    class Activity < ApplicationRecord

      belongs_to :actor, polymorphic: true
      belongs_to :impersonated_by, polymorphic: true, optional: true
      belongs_to :target, polymorphic: true
      belongs_to :application_activity, polymorphic: true

      validates :actor, :target, :target_event, :application_activity, presence: true

      # Make records readonly after they have been persisted
      def readonly?
         persisted?
      end

      def component_class
        # 1. Explicit mapping on the ApplicationActivity subclass (gem activities)
        explicit = application_activity_class.component_class
        return explicit if explicit

        # 2. Infer mapping from ApplicationActivity subclass name
        inferred = infer_host_component_class(application_activity_class)
        return inferred if inferred

        # 3. Fallback to gem-provided generic component
        fallback_component_class
      end

      private

      def application_activity_class
        # application_activity is polymorphic, always present here
        application_activity.class
      end

      def infer_host_component_class(klass)
        component_name = "#{klass.name}Component"
        component_name.safe_constantize
      rescue NameError
        nil
      end

      def fallback_component_class
        ApplicationActivities::FallbackComponent
      end
    end
  end
end
