require 'rails_helper'

RSpec.describe Oscar::Audit::ApplicationLog, type: :model do
  include WithModel

  with_model :TestActor do
    table do |t|
      t.string :name
    end
  end

  with_model :TestTarget do
    table do |t|
      t.string :name
    end
  end

  with_model :AppEvent, superclass: Oscar::Audit::ApplicationLog do
    table do |t|
      t.string :title
      t.timestamps null: false
    end
  end

  describe 'associations' do
    subject { AppEvent.new }

    it { is_expected.to have_one(:log).class_name('Oscar::Audit::Log') }

    it 'defines log association as polymorphic application_log' do
      reflection = described_class.reflect_on_association(:log)
      expect(reflection.options[:as]).to eq(:application_log)
      expect(reflection.class_name).to eq('Oscar::Audit::Log')
    end
  end

  describe 'integration with Oscar::Audit::Log' do
    it 'can be associated to a log with actor and target' do
      event = AppEvent.create!(title: 'Something happened')

      # No automatic log creation
      expect(event.log).to be_nil

      actor = TestActor.create!(name: 'Alice')
      target = TestTarget.create!(name: 'Resource')

      log = Oscar::Audit::Log.create!(
        actor: actor,
        target: target,
        application_log: event
      )

      expect(log.application_log).to eq(event)
      expect(event.reload.log).to eq(log)
      expect(log.actor).to eq(actor)
      expect(log.target).to eq(target)
    end
  end

  describe '#handle' do
    with_model :UnhandledEvent, superclass: Oscar::Audit::ApplicationLog do
      table do |t|
        t.string :foo
      end
    end

    it 'raises NotImplementedError in the base implementation' do
      event = UnhandledEvent.create!(foo: 'bar')
      expect {
        event.handle('test.event', Time.now, Time.now, '123', { any: 'payload' })
      }.to raise_error(NotImplementedError, /You must implement handle/)
    end
  end
end
