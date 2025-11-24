Oscar::Activities.disable_application_logs!

RSpec.configure do |config|

  config.before :each, type: :feature do
    Oscar::Activities.enable_application_logs!
  end

  config.before :each, require_application_logs: true do |example|
    unless example.metadata[:type] == :feature
      # feature test already have the seed loaded (see above)
      Oscar::Activities.enable_application_logs!
    end
  end
end
