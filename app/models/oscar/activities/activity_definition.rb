# app/models/oscar/activities/activity_definition.rb
module Oscar
  module Activities
    class ActivityDefinition < ApplicationRecord

      has_many :activities,
               class_name: "Oscar::Activities::Activity",
               foreign_key: :activity_definition_id,
               dependent: :destroy

      validates :model_type, :model_event_name, :log_type, presence: true

      # Returns the constantized log class (e.g. "ShipmentCreationLog" → ShipmentCreationLog)
      def log_class
        log_type.safe_constantize
      end


    end
  end
end
