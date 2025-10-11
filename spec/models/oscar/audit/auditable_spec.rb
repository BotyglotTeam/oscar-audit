require 'rails_helper'

RSpec.describe 'Oscar::Audit::Auditable DSL' do
  include WithModel

  with_model :TestTarget do
    table do |t|
      t.string :name
    end

    model do
      audit_log 'test.event', 'HandledEvent'
    end
  end

  with_model :HandledEvent, superclass: Oscar::Audit::ApplicationLog do
    table do |t|
      t.string :note
      t.timestamps null: false
    end

    model do
      def handle(name, start, finish, id, payload)
        # no-op in test
      end
    end
  end

  it 'subscribes to ActiveSupport::Notifications and invokes handler#handle with proper argument types' do
    # Ensure model classes are loaded
    target = TestTarget.create!(name: 'Resource')
    expect(target).to be_present

    expect_any_instance_of(HandledEvent).to receive(:handle) do |instance, name, start, finish, id, payload|
      expect(instance).to be_a(HandledEvent)
      expect(name).to be_a(String)
      expect(name).to eq('test.event')
      expect(start).to be_a(Time)
      expect(finish).to be_a(Time)
      expect(finish).to be >= start
      expect(id).to be_a(String)
      expect(payload).to be_a(Hash)
      expect(payload).to include(foo: 'bar')
    end

    Oscar::Audit.with_application_logs do
      ActiveSupport::Notifications.instrument('test.event', foo: 'bar') do
        # simulate work
      end
    end
  end
end
