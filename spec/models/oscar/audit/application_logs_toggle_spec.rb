require 'rails_helper'

RSpec.describe 'Oscar::Audit application logs toggle' do
  include WithModel

  with_model :ToggleTestTarget do
    table do |t|
      t.string :name
    end

    model do
      audit_log 'toggle.event', 'ToggleHandledEvent'
    end
  end

  with_model :ToggleHandledEvent, superclass: Oscar::Audit::ApplicationLog do
    table do |t|
      t.string :note
      t.timestamps null: false
    end

    model do
      def handle(name, start, finish, id, payload)
        # no-op for testing
      end
    end
  end

  before do
    # Ensure the model classes are loaded
    ToggleTestTarget.create!(name: 'X')
  end

  it 'is enbled by default in test environment' do
    expect_any_instance_of(ToggleHandledEvent).to receive(:handle).once

    ActiveSupport::Notifications.instrument('toggle.event', foo: 'bar') do
      # do nothing
    end
  end

  it 'disables within without_application_logs' do
    expect_any_instance_of(ToggleHandledEvent).not_to receive(:handle)

    Oscar::Audit.without_application_logs do
      ActiveSupport::Notifications.instrument('toggle.event', foo: 'bar') do
      end
    end
  end

  it 'enables within with_application_logs when disabled by default in test' do
    expect_any_instance_of(ToggleHandledEvent).to receive(:handle).once

    Oscar::Audit.with_application_logs do
      ActiveSupport::Notifications.instrument('toggle.event', foo: 'bar') do
      end
    end
  end

  it 're-enables within with_application_logs even if outer scope disabled' do
    calls = 0
    allow_any_instance_of(ToggleHandledEvent).to receive(:handle) { calls += 1 }

    Oscar::Audit.without_application_logs do
      # Disabled here
      Oscar::Audit.with_application_logs do
        # Re-enabled inside
        ActiveSupport::Notifications.instrument('toggle.event', foo: 'bar') do
        end
      end
    end

    expect(calls).to eq(1)
  end

  it 'disable_application_logs! is global across threads' do
    begin
      Oscar::Audit.disable_application_logs!
      expect_any_instance_of(ToggleHandledEvent).not_to receive(:handle)

      t = Thread.new do
        ActiveSupport::Notifications.instrument('toggle.event', foo: 'bar') do
        end
      end
      t.join
    ensure
      Oscar::Audit.enable_application_logs!
    end
  end

  it 'enable_application_logs! is global across threads' do
    begin
      Oscar::Audit.disable_application_logs! # start from OFF globally
      expect_any_instance_of(ToggleHandledEvent).to receive(:handle).once

      Oscar::Audit.enable_application_logs!

      t = Thread.new do
        ActiveSupport::Notifications.instrument('toggle.event', foo: 'bar') do
        end
      end
      t.join
    ensure
      Oscar::Audit.enable_application_logs!
    end
  end
end
