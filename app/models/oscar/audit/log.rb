# app/models/oscar/audit/log.rb
module Oscar
  module Audit
    class Log < ApplicationRecord

      belongs_to :actor, polymorphic: true
      belongs_to :impersonated_by, polymorphic: true, optional: true
      belongs_to :target, polymorphic: true
      belongs_to :application_log, polymorphic: true

      validates :actor, :target, :target_event, :application_log, presence: true
    end
  end
end
