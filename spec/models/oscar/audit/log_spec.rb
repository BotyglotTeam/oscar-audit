# frozen_string_literal: true

require "rails_helper"

RSpec.describe Oscar::Audit::Log, type: :model do


  describe "associations" do
    subject(:log) { described_class.new }

    it { is_expected.to belong_to(:actor) }
    it { is_expected.to belong_to(:impersonated_by).optional }
    it { is_expected.to belong_to(:target) }
    it { is_expected.to belong_to(:application_log) }
  end

  describe "validations" do
    subject(:log) { described_class.new }

    it { is_expected.to validate_presence_of(:actor) }
    it { is_expected.to validate_presence_of(:target) }
    it { is_expected.to validate_presence_of(:target_event) }
    it { is_expected.to validate_presence_of(:application_log) }
  end
end
