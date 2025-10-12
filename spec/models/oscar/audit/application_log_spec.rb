# frozen_string_literal: true

require "rails_helper"
require "securerandom"

RSpec.describe Oscar::Audit::ApplicationLog, type: :model do
  # Ephemeral models to make tests readable
  with_model :TestActor do
    table do |t|
      t.string :name
      t.timestamps
    end
  end

  with_model :TestTarget do
    table do |t|
      t.string :name
      t.timestamps
    end
  end

  # Minimal child class of ApplicationLog used for tests
  with_model :HandledEvent, superclass: Oscar::Audit::ApplicationLog do
    table do |t|
      t.string :note
      t.timestamps
    end

    model do
      # Minimal logic to allow creating the associated audit log
      # by setting the required accessors from the notification payload
      def handle(event_name, started_at, finished_at, event_id, payload)
        self.actor = payload[:actor]
        self.target = payload[:target]
        self.target_event = event_name.split(".").last
        self.impersonated_by = payload[:impersonated_by]
        self
      end
    end
  end

  let(:actor)  { TestActor.create!(name: "Alice") }
  let(:target) { TestTarget.create!(name: "Document") }

  describe "associations" do
    subject(:app_log) { HandledEvent.new }

    it { is_expected.to have_one(:log).class_name("Oscar::Audit::Log") }
  end

  describe "after_create_commit" do
    it "creates a Log linked to actor, target and application_log" do
      expect {
        HandledEvent.create!(actor: actor, target: target, target_event: "done")
      }.to change { Oscar::Audit::Log.count }.by(1)

      app_log = HandledEvent.last
      log = app_log.log
      expect(log).to be_present
      expect(log.actor).to eq(actor)
      expect(log.target).to eq(target)
      expect(log.target_event).to eq('done')
      expect(log.application_log).to eq(app_log)
    end
  end

  describe ".tracks" do
    it "raises when event_name is not a String" do
      expect { HandledEvent.tracks(:not_a_string) }
        .to raise_error(ArgumentError, /must be a String/)
    end

    it "subscribes once per subclass and processes events when enabled" do
      event_name = "audit.test_event.#{SecureRandom.hex(4)}"

      # Calling twice should not create duplicate subscriptions
      HandledEvent.tracks(event_name)
      HandledEvent.tracks(event_name)

      expect {
        Oscar::Audit.with_application_logs do
          ActiveSupport::Notifications.instrument(event_name, actor: actor, target: target)
        end
      }.to change { HandledEvent.count }.by(1)
       .and change { Oscar::Audit::Log.count }.by(1)
    end

    it "does not process events when application logs are disabled" do
      event_name = "audit.disabled_event.#{SecureRandom.hex(4)}"

      HandledEvent.tracks(event_name)

      expect {
        Oscar::Audit.without_application_logs do
          ActiveSupport::Notifications.instrument(event_name, actor: actor, target: target)
        end
      }.to change(HandledEvent, :count).by(0)
       .and change(Oscar::Audit::Log, :count).by(0)
    end
  end

  describe ".handle" do
    it "instantiates, calls instance#handle, saves the record and creates the associated log" do
      instrumenter_id = SecureRandom.uuid
      expect {
        HandledEvent.handle("evt", Time.current, Time.current, instrumenter_id, { actor: actor, target: target })
      }.to change { HandledEvent.count }.by(1)
       .and change { Oscar::Audit::Log.count }.by(1)

      record = HandledEvent.last
      expect(record.log).to be_present
      expect(record.log.actor).to eq(actor)
      expect(record.log.target).to eq(target)
    end
  end

  describe ".exists?" do
    it "returns false by default on the base class and simple subclasses" do
      instrumenter_id = SecureRandom.uuid
      expect(HandledEvent.exists?("evt", Time.current, Time.current, instrumenter_id, {})).to eq(false)
    end

    # Subclass overriding .exists? to prevent duplicates based on instrumenter_id
    with_model :DedupHandledEvent, superclass: Oscar::Audit::ApplicationLog do
      table do |t|
        t.string :event_uuid
        t.timestamps
      end

      model do
        def self.exists?(event_name, started_at, finished_at, instrumenter_id, payload)
          where(event_uuid: payload[:event_id]).exists?
        end

        def handle(event_name, started_at, finished_at, instrumenter_id, payload)
          self.actor = payload[:actor]
          self.target = payload[:target]
          self.target_event = event_name.split(".").last
          self.event_uuid = payload[:event_id]
          self
        end
      end
    end

    it "does not create duplicates when a child class overrides .exists?" do
      instrumenter_id = SecureRandom.uuid
      event_id = SecureRandom.uuid

      expect {
        2.times do
          DedupHandledEvent.handle("audit.something", Time.current, Time.current, instrumenter_id, { actor: actor, target: target, event_id: event_id })
        end
      }.to change { DedupHandledEvent.count }.by(1)
       .and change { Oscar::Audit::Log.count }.by(1)
    end

    it "creates separate records for different instrumenter IDs" do
      instrumenter_id = SecureRandom.uuid
      event_id1 = SecureRandom.uuid
      event_id2 = SecureRandom.uuid

      expect {
        DedupHandledEvent.handle("audit.something", Time.current, Time.current, instrumenter_id, { actor: actor, target: target, event_id: event_id1  })
        DedupHandledEvent.handle("audit.something", Time.current, Time.current, instrumenter_id, { actor: actor, target: target, event_id: event_id2  })
      }.to change { DedupHandledEvent.count }.by(2)
       .and change { Oscar::Audit::Log.count }.by(2)
    end
  end
end
