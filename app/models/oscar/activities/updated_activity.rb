module Oscar
  module Activities
    class UpdatedActivity < ApplicationActivity
      belongs_to :version_record, polymorphic: true
    end
  end
end
