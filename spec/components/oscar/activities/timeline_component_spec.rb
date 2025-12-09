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

  describe "with activities" do


    let(:application_activity) { TestActivity.create! }
    let(:activities) do
      [
        Oscar::Activities::Activity.new(
          id: 1,
          created_at: 2.days.ago,
          application_activity: application_activity
        )
      ]
    end

    subject(:component) do
      described_class.new(activities: activities, current_actor: current_actor)
    end

    before do
      allow(activities.first).to receive(:component).and_return(
        Oscar::Activities::FallbackComponent.new(
          application_activity: application_activity,
          actor: current_actor
        )
      )
    end

    describe "#initialize" do
      it "accepts activities and current_actor" do
        expect { component }.not_to raise_error
      end
    end

    describe "rendering" do
      it "renders the timeline container" do
        render_inline(component)

        expect(page).to have_css("div.oscar-activities-timeline")
      end

      it "renders the timeline-container when activities exist" do
        render_inline(component)

        expect(page).to have_css("div.timeline-container")
      end

      it "renders activity items" do
        render_inline(component)

        expect(page).to have_css("div.timeline-activity-item")
      end

      it "includes activity ID in data attribute" do
        render_inline(component)

        expect(page).to have_css('div.timeline-activity-item[data-activity-id="1"]')
      end

      it "includes activity type in data attribute" do
        render_inline(component)

        expect(page).to have_css('div.timeline-activity-item[data-activity-type="TestActivity"]')
      end

      it "renders activity timestamp" do
        render_inline(component)

        expect(page).to have_css("div.activity-timestamp")
      end

      it "renders activity content" do
        render_inline(component)

        expect(page).to have_css("div.activity-content")
      end

      it "calls render_activity for each activity" do
        allow(component).to receive(:render_activity).and_call_original

        render_inline(component)

        expect(component).to have_received(:render_activity).with(
          activity: activities.first,
          actor: current_actor
        )
      end
    end
  end

  describe "with multiple activities" do

    let(:application_activity1) { TestActivity.create! }
    let(:application_activity2) { TestActivity.create! }
    let(:activities) do
      [
        Oscar::Activities::Activity.new(
          id: 1,
          created_at: 2.days.ago,
          application_activity: application_activity1
        ),
        Oscar::Activities::Activity.new(
          id: 2,
          created_at: 1.day.ago,
          application_activity: application_activity2
        )
      ]
    end

    subject(:component) do
      described_class.new(activities: activities, current_actor: current_actor)
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

    it "renders all activities" do
      render_inline(component)

      expect(page).to have_css("div.timeline-activity-item", count: 2)
    end

    it "includes data attributes for each activity" do
      render_inline(component)

      expect(page).to have_css('div.timeline-activity-item[data-activity-id="1"]')
      expect(page).to have_css('div.timeline-activity-item[data-activity-id="2"]')
    end
  end

  describe "with no activities" do
    let(:activities) { [] }

    subject(:component) do
      described_class.new(activities: activities, current_actor: current_actor)
    end

    it "renders the empty state" do
      render_inline(component)

      expect(page).to have_css("div.timeline-empty")
    end

    it "displays the empty message" do
      render_inline(component)

      expect(page).to have_css("p.timeline-empty-message", text: "No activities to display.")
    end

    it "does not render timeline-container" do
      render_inline(component)

      expect(page).not_to have_css("div.timeline-container")
    end
  end

  describe "with orphaned activity (missing application_activity)" do
    let(:orphaned_activity) do
      Oscar::Activities::Activity.new(
        id: 999,
        created_at: 3.days.ago,
        application_activity: nil
      )
    end
    let(:activities) { [orphaned_activity] }

    subject(:component) do
      described_class.new(activities: activities, current_actor: current_actor)
    end

    before do
      allow(orphaned_activity).to receive(:component).and_return(
        Oscar::Activities::ApplicationActivityMissingComponent.new(
          activity: orphaned_activity,
          actor: current_actor
        )
      )
    end

    it "renders the activity with ApplicationActivityMissingComponent" do
      render_inline(component)

      expect(page).to have_css("div.activity-missing-data")
    end

    it "does not include activity type in data attribute when application_activity is missing" do
      render_inline(component)

      expect(page).to have_css('div.timeline-activity-item[data-activity-type=""]')
    end
  end
end
