module Oscar
  module Activities
    class Engine < ::Rails::Engine
      engine_name "oscar_activities"
      isolate_namespace Oscar::Activities
    end
  end
end
