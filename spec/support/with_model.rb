# Support for with-model to define ephemeral ActiveRecord models in specs
require 'with_model'

RSpec.configure do |config|
  config.extend WithModel
end

