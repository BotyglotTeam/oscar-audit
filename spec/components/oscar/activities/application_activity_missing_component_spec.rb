require "rails_helper"

RSpec.describe Oscar::Activities::ApplicationActivityMissingComponent, type: :component do
  let(:activity) { Oscar::Activities::Activity.new(id: 123, created_at: 2.days.ago) }
  let(:actor) { Oscar::Activities::Actor.system }

  it "renders missing activity message with ID and timestamp" do
    render_inline(described_class.new(activity: activity, actor: actor))

    expect(page).to have_css("div.activity-missing-data") do |div|
      expect(div).to have_css("strong", text: "Activity #123")
      expect(div).to have_text("is missing its associated application activity data")
      expect(div).to have_css("span.text-muted", text: /created .* ago/)
    end
  end
end
