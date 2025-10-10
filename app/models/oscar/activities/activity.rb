# app/models/oscar/activities/activity.rb
module Oscar
  module Activities
    class Activity < ApplicationRecord

      belongs_to :activity_definition,
                 class_name: "Oscar::Activities::ActivityDefinition"

      belongs_to :actor, polymorphic: true
      belongs_to :impersonated_by, polymorphic: true, optional: true
      belongs_to :target, polymorphic: true
      belongs_to :log, polymorphic: true, optional: true

      validates :activity_definition, :actor, :target, presence: true

    end
  end
end
