# frozen_string_literal: true

require "rails/generators"
require "oscar/activities/yaml_loader"

module Oscar
  module Activities
    module Generators
      class InstallGenerator < Rails::Generators::Base
        desc "Creates a default #{Oscar::Activities::YamlLoader::RELATIVE_CONFIG_PATH} configuration file."

        source_root File.expand_path("templates", __dir__)

        def create_config_file
          destination = Oscar::Activities::YamlLoader::RELATIVE_CONFIG_PATH

          if File.exist?(destination)
            say_status :exist, destination
          else
            copy_file "oscar_activities.yml", destination
          end
        end

        def install_migrations
          say_status :invoke, "oscar_activities:install:migrations"
          # Use Rails' command helper to copy the engine migrations into the host app
          rails_command "oscar_activities:install:migrations"
        rescue StandardError => e
          say_status :error, "Failed to install migrations: #{e.message}", :red
        end
      end
    end
  end
end
