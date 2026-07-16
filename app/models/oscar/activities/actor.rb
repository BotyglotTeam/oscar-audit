# app/models/oscar/activities/actor.rb
module Oscar
  module Activities
    class Actor < ApplicationRecord
      # We intentionally use a column named `type` for an enum.
      # Disable STI so ActiveRecord doesn't treat this as inheritance.
      self.inheritance_column = :_type_disabled

      enum :type, { visitor: 0, system: 1 }

      def self.visitor
        actor = find_by(type: :visitor)
        return actor if actor.present?

        create!(type: :visitor, name: "Visitor")
      end

      def self.system
        actor = find_by(type: :system)
        return actor if actor.present?

        create!(type: :system, name: "System")
      end
    end
  end
end
