require "yaml"
module Oscar
  module Activities
    class YamlLoader
      CONFIG_PATH = Rails.root.join("config/oscar_activities.yml")

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