module Oscar
  module Activities
    class CreatedActivity < ApplicationActivity
      belongs_to :version_record, polymorphic: true
    end
  end
end
