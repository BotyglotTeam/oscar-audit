# app/models/oscar/audit/activity.rb
module Oscar
  module Audit
    class Activity < ApplicationRecord

      belongs_to :actor, polymorphic: true
      belongs_to :impersonated_by, polymorphic: true, optional: true
      belongs_to :target, polymorphic: true
      belongs_to :log, polymorphic: true, optional: true

      validates :actor, :target, presence: true

    end
  end
end
