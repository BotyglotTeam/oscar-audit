# frozen_string_literal: true

require "rails/generators/base"

module Oscar
  module Audit
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)
        desc "Installs Oscar Audit Gem"

        def create_files
          template "app/models/application_log.rb.erb", "app/models/application_log.rb"
          template "spec/support/oscar_audit.rb.erb", "spec/support/oscar_audit.rb"
        end

        # Also copy the engine's migrations into the host app
        def copy_migrations
          rake "railties:install:migrations FROM=oscar_audit"
        end
      end
    end
  end
end
