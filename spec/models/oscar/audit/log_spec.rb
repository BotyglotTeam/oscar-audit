require 'rails_helper'

RSpec.describe Oscar::Audit::Log, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:actor) }
    it 'has a polymorphic actor association' do
      reflection = described_class.reflect_on_association(:actor)
      expect(reflection.polymorphic?).to be(true)
    end

    it { is_expected.to belong_to(:impersonated_by).optional }
    it 'has a polymorphic impersonated_by association' do
      reflection = described_class.reflect_on_association(:impersonated_by)
      expect(reflection.polymorphic?).to be(true)
    end

    it { is_expected.to belong_to(:target) }
    it 'has a polymorphic target association' do
      reflection = described_class.reflect_on_association(:target)
      expect(reflection.polymorphic?).to be(true)
    end

    it { is_expected.to belong_to(:log).optional }
    it 'has a polymorphic log association' do
      reflection = described_class.reflect_on_association(:log)
      expect(reflection.polymorphic?).to be(true)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:actor) }
    it { is_expected.to validate_presence_of(:target) }
  end
end
