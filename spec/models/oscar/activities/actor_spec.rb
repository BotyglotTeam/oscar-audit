# frozen_string_literal: true

require "rails_helper"

RSpec.describe Oscar::Activities::Actor, type: :model do
  describe "enums" do
    it { is_expected.to define_enum_for(:type).with_values(%i[visitor system]).backed_by_column_of_type(:integer) }
  end

  describe ".visitor" do
    it "creates the visitor actor when it does not exist" do
      expect { described_class.visitor }.to change { described_class.count }.by(1)
      actor = described_class.visitor
      expect(actor).to be_persisted
      expect(actor.type).to eq("visitor")
      expect(actor.name).to eq("Visitor")
    end

    it "returns the existing visitor actor without creating a new record" do
      existing = described_class.create!(type: :visitor, name: "Visitor")
      expect { described_class.visitor }.not_to change { described_class.count }
      expect(described_class.visitor.id).to eq(existing.id)
    end
  end

  describe ".system" do
    it "creates the system actor when it does not exist" do
      expect { described_class.system }.to change { described_class.count }.by(1)
      actor = described_class.system
      expect(actor).to be_persisted
      expect(actor.type).to eq("system")
      expect(actor.name).to eq("System")
    end

    it "returns the existing system actor without creating a new record" do
      existing = described_class.create!(type: :system, name: "System")
      expect { described_class.system }.not_to change { described_class.count }
      expect(described_class.system.id).to eq(existing.id)
    end
  end
end


RSpec.describe Oscar::Activities::Actor, type: :model do
  describe "name customization persistence" do
    it "keeps modified name for visitor and does not create a new record" do
      actor = described_class.visitor
      actor.update!(name: "Guest")

      expect { described_class.visitor }.not_to change { described_class.count }

      found = described_class.visitor
      expect(found.id).to eq(actor.id)
      expect(found.reload.name).to eq("Guest")
    end

    it "keeps modified name for system and does not create a new record" do
      actor = described_class.system
      actor.update!(name: "Robot")

      expect { described_class.system }.not_to change { described_class.count }

      found = described_class.system
      expect(found.id).to eq(actor.id)
      expect(found.reload.name).to eq("Robot")
    end
  end
end
