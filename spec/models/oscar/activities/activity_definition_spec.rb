require 'rails_helper'

RSpec.describe Oscar::Activities::ActivityDefinition, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:activities).class_name('Oscar::Activities::Activity').dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:model_type) }
    it { is_expected.to validate_presence_of(:model_event_name) }
    it { is_expected.to validate_presence_of(:log_type) }
  end

  describe '#log_class' do
    it 'returns the constantized class when log_type is a valid constant' do
      model = described_class.new(model_type: 'Order', model_event_name: 'created', log_type: 'String')
      expect(model.log_class).to eq(String)
    end

    it 'returns nil when log_type cannot be constantized' do
      model = described_class.new(model_type: 'Order', model_event_name: 'created', log_type: 'NotARealClass')
      expect(model.log_class).to be_nil
    end
  end
end
