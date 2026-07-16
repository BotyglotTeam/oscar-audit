module Oscar
  module Activities
    class DestroyedActivity < ApplicationActivity
      belongs_to :version_record, polymorphic: true
    end
  end
end
