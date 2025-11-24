# frozen_string_literal: true

require "rails_helper"

RSpec.describe Oscar::Activities::Activity, type: :model do
  # Ephemeral models for associations
  with_model :LogSpecActor do
    table do |t|
      t.string :name
      t.timestamps
    end
  end

  with_model :LogSpecTarget do
    table do |t|
      t.string :name
      t.timestamps
    end
  end

  with_model :LogSpecApplicationLog do
    table do |t|
      t.string :note
      t.timestamps
    end
  end

  let(:actor)  { LogSpecActor.create!(name: "A") }
  let(:target) { LogSpecTarget.create!(name: "T") }
  let(:app_activity){ LogSpecApplicationLog.create!(note: "n") }

  describe "associations" do
    subject(:log) { described_class.new }

    it { is_expected.to belong_to(:actor) }
    it { is_expected.to belong_to(:impersonated_by).optional }
    it { is_expected.to belong_to(:target) }
    it { is_expected.to belong_to(:application_activity) }
  end

  describe "validations" do
    subject(:log) { described_class.new }

    it { is_expected.to validate_presence_of(:actor) }
    it { is_expected.to validate_presence_of(:target) }
    it { is_expected.to validate_presence_of(:target_event) }
    it { is_expected.to validate_presence_of(:application_activity) }
  end

  describe "readonly after persistence" do
    it "raises ActiveRecord::ReadOnlyRecord on update after create" do
      log = described_class.create!(actor: actor, target: target, application_activity: app_activity, target_event: "done")
      expect {
        log.update!(target_event: "changed")
      }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it "raises ActiveRecord::ReadOnlyRecord on destroy after create" do
      log = described_class.create!(actor: actor, target: target, application_activity: app_activity, target_event: "done")
      expect {
        log.destroy!
      }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end
