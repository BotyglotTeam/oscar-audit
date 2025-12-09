require "rails_helper"

RSpec.describe Oscar::Activities::ApplicationActivityMissingComponent, type: :component do
  let(:activity) { Oscar::Activities::Activity.new(id: 123, created_at: 2.days.ago) }
  let(:actor) { double("Actor") }

  subject(:component) do
    described_class.new(activity: activity, actor: actor)
  end

  describe "#call" do
    it "renders a div with class 'activity-missing-data'" do
      render_inline(component)

      expect(page).to have_css("div.activity-missing-data")
    end

    it "displays the activity ID" do
      render_inline(component)

      expect(page).to have_css("strong", text: "Activity #123")
    end

    it "includes message about missing application activity data" do
      render_inline(component)

      expect(page).to have_text("is missing its associated application activity data")
    end

    it "displays time ago in words for when the activity was created" do
      render_inline(component)

      expect(page).to have_css("span.text-muted", text: /created .* ago/)
    end

    it "shows '2 days' in the time ago text" do
      render_inline(component)

      expect(page).to have_text("2 days")
    end
  end

  describe "#initialize" do
    it "accepts activity and actor" do
      expect { component }.not_to raise_error
    end

    it "stores activity as an attribute" do
      expect(component.send(:activity)).to eq(activity)
    end

    it "stores actor as an attribute" do
      expect(component.send(:actor)).to eq(actor)
    end
  end
end
