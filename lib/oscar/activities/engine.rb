module Oscar
  module Activities
    class Engine < ::Rails::Engine
      isolate_namespace Oscar::Activities
    end
  end
end
