require "rails_helper"

RSpec.describe Oscar::Activities::FallbackComponent, type: :component do
  with_model :TestActivity, superclass: Oscar::Activities::ApplicationActivity do
    table do |t|
      t.timestamps
    end
  end

  let(:application_activity) { TestActivity.new }
  let(:actor) { double("Actor") }

  subject(:component) do
    described_class.new(application_activity: application_activity, actor: actor)
  end

  describe "#call" do
    it "renders a div with fallback message" do
      render_inline(component)

      expect(page).to have_css("div", text: /Please add the component to render activities of type/)
    end

    it "includes the activity class name in the message" do
      render_inline(component)

      expect(page).to have_text("Please add the component to render activities of type TestActivity")
    end
  end

  describe "#initialize" do
    it "accepts application_activity and actor" do
      expect { component }.not_to raise_error
    end

    it "accepts and ignores additional keyword arguments" do
      expect do
        described_class.new(
          application_activity: application_activity,
          actor: actor,
          extra_arg: "value"
        )
      end.not_to raise_error
    end
  end
end
