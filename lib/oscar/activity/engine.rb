module Oscar
  module Activity
    class Engine < ::Rails::Engine
      isolate_namespace Oscar::Activity
    end
  end
end
