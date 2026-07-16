# frozen_string_literal: true

require "rails/generators/base"

module Oscar
  module Activities
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)
        desc "Installs Oscar Activities Gem"

        def create_files
          template "app/models/application_activity.rb.erb", "app/models/application_activity.rb"
          template "spec/support/oscar_activities.rb.erb", "spec/support/oscar_activities.rb"
        end

        # Also copy the engine's migrations into the host app
        def copy_migrations
          rake "railties:install:migrations FROM=oscar_activities"
        end
      end
    end
  end
end
