module Oscar
  module Audit
    class Engine < ::Rails::Engine
      isolate_namespace Oscar::Audit
    end
  end
end
