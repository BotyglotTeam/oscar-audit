require "rails_helper"

RSpec.describe Oscar::Activities::FallbackComponent, type: :component do
  with_model :TestActivity, superclass: Oscar::Activities::ApplicationActivity do
    table do |t|
      t.timestamps
    end
  end

  let(:application_activity) { TestActivity.new }
  let(:actor) { Oscar::Activities::Actor.system }

  it "renders fallback message with activity class name" do
    render_inline(described_class.new(application_activity: application_activity, actor: actor))

    expect(page).to have_text("Please add the component to render activities of type TestActivity")
  end

  it "accepts additional keyword arguments" do
    expect do
      described_class.new(
        application_activity: application_activity,
        actor: actor,
        extra_arg: "value"
      )
    end.not_to raise_error
  end
end
