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
    end
  end
end
