require_relative "lib/oscar/activities/version"

Gem::Specification.new do |spec|
  spec.name        = "oscar-activities"
  spec.version     = Oscar::Activities::VERSION
  spec.authors     = [ "Dorian" ]
  spec.email       = [ "dorian@botyglot.com" ]
  spec.homepage    = "https://github.com/BotyglotTeam/oscar-activities"
  spec.summary     = "Easy activity tracking for models"
  spec.description = "Provides activity tracking for your ActiveRecord models in Rails 8.0+."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/BotyglotTeam/oscar-activities"
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.3"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "factory_bot_rails"
end
