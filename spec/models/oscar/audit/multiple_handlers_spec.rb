require 'rails_helper'

RSpec.describe 'Multiple application log handlers for the same event' do
  include WithModel

  with_model :MultiTarget do
    table do |t|
      t.string :name
    end

    model do
      audit_log 'multi.event', 'FirstHandler'
      audit_log 'multi.event', 'SecondHandler'
    end
  end

  with_model :FirstHandler, superclass: Oscar::Audit::ApplicationLog do
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

  with_model :SecondHandler, superclass: Oscar::Audit::ApplicationLog do
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

  it 'invokes all handlers subscribed to the same event exactly once' do
    # Load models
    MultiTarget.create!(name: 'Resource')

    expect_any_instance_of(FirstHandler).to receive(:handle).once
    expect_any_instance_of(SecondHandler).to receive(:handle).once

    Oscar::Audit.with_application_logs do
      ActiveSupport::Notifications.instrument('multi.event', foo: 'bar') do
        # work
      end
    end
  end
end
