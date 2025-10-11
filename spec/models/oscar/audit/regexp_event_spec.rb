require 'rails_helper'

RSpec.describe 'Regexp event subscription support' do
  include WithModel

  with_model :RegexTarget do
    table do |t|
      t.string :name
    end

    model do
      audit_log(/regex\.event\..+/, 'RegexHandledEvent')
    end
  end

  with_model :RegexHandledEvent, superclass: Oscar::Audit::ApplicationLog do
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

  it 'invokes the handler when a matching event name is instrumented' do
    RegexTarget.create!(name: 'Resource')

    expect_any_instance_of(RegexHandledEvent).to receive(:handle) do |instance, name, *_rest|
      expect(name).to be_a(String)
      expect(name).to match(/regex\.event\..+/)
    end

    Oscar::Audit.with_application_logs do
      ActiveSupport::Notifications.instrument('regex.event.created', foo: 'bar') do
      end
    end
  end
end