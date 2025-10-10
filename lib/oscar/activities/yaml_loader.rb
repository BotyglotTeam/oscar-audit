require "yaml"
module Oscar
  module Activities
    class YamlLoader
      # Single source of truth for the config file relative path
      RELATIVE_CONFIG_PATH = "config/oscar_activities.yml"
      CONFIG_PATH = Rails.root.join(RELATIVE_CONFIG_PATH)

      def self.load_definitions
        return [] unless File.exist?(CONFIG_PATH)

        raw_yaml = File.read(CONFIG_PATH)
        erb_result = ERB.new(raw_yaml).result

        parsed_yaml = YAML.safe_load(erb_result, aliases: true) || {}

        parsed_yaml["activity_definitions"]
      rescue Psych::SyntaxError => e
        Rails.logger.error("[Oscar::Activities] YAML syntax error: #{e.message}")
        []
      end
    end
  end
end