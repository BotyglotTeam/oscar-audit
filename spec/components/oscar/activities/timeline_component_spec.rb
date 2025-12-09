require "rails_helper"

RSpec.describe Oscar::Activities::TimelineComponent, type: :component do
  let(:current_actor) { Oscar::Activities::Actor.system }

  with_model :TestActivity, superclass: Oscar::Activities::ApplicationActivity do
    table do |t|
      t.timestamps
    end

    model do
      def actor
        Oscar::Activities::Actor.system
      end

      def target
        Oscar::Activities::Actor.system
      end

      def target_event
        "test"
      end
    end
  end

  context "with activities" do
    let(:application_activity) { TestActivity.create! }
    let(:activity) do
      Oscar::Activities::Activity.new(
        id: 1,
        created_at: 2.days.ago,
        application_activity: application_activity
      )
    end
    let(:activities) { [activity] }

    before do
      allow(activity).to receive(:component).and_return(
        Oscar::Activities::FallbackComponent.new(
          application_activity: application_activity,
          actor: current_actor
        )
      )
    end

    it "renders timeline with activity items and data attributes" do
      render_inline(described_class.new(activities: activities, current_actor: current_actor))

      expect(page).to have_css("div.oscar-activities-timeline div.timeline-container") do |container|
        expect(container).to have_css('div.timeline-activity-item[data-activity-id="1"][data-activity-type="TestActivity"]')
        expect(container).to have_css("div.activity-timestamp")
        expect(container).to have_css("div.activity-content")
      end
    end
  end

  context "with multiple activities" do
    let(:activities) do
      [
        Oscar::Activities::Activity.new(id: 1, created_at: 2.days.ago, application_activity: TestActivity.create!),
        Oscar::Activities::Activity.new(id: 2, created_at: 1.day.ago, application_activity: TestActivity.create!)
      ]
    end

    before do
      activities.each do |activity|
        allow(activity).to receive(:component).and_return(
          Oscar::Activities::FallbackComponent.new(
            application_activity: activity.application_activity,
            actor: current_actor
          )
        )
      end
    end

    it "renders all activity items" do
      render_inline(described_class.new(activities: activities, current_actor: current_actor))

      expect(page).to have_css("div.timeline-activity-item", count: 2)
      expect(page).to have_css('div.timeline-activity-item[data-activity-id="1"]')
      expect(page).to have_css('div.timeline-activity-item[data-activity-id="2"]')
    end
  end

  context "without activities" do
    it "renders empty state message" do
      render_inline(described_class.new(activities: [], current_actor: current_actor))

      expect(page).to have_css("div.timeline-empty p.timeline-empty-message", text: "No activities to display.")
      expect(page).not_to have_css("div.timeline-container")
    end
  end

  context "with orphaned activity" do
    let(:orphaned_activity) do
      Oscar::Activities::Activity.new(id: 999, created_at: 3.days.ago, application_activity: nil)
    end

    before do
      allow(orphaned_activity).to receive(:component).and_return(
        Oscar::Activities::ApplicationActivityMissingComponent.new(
          activity: orphaned_activity,
          actor: current_actor
        )
      )
    end

    it "renders missing activity component" do
      render_inline(described_class.new(activities: [orphaned_activity], current_actor: current_actor))

      expect(page).to have_css("div.activity-missing-data")
      expect(page).to have_css('div.timeline-activity-item[data-activity-type=""]')
    end
  end
end
