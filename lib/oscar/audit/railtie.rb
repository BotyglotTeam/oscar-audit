# lib/oscar/audit/railtie.rb
module Oscar
  module Audit
    class Railtie < ::Rails::Railtie
      initializer "oscar.audit.auditable" do
        ActiveSupport.on_load(:active_record) do
          require "oscar/audit/auditable"
          ActiveRecord::Base.include(::Oscar::Audit::Auditable)
        end
      end
    end
  end
end
