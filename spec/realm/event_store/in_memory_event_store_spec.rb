require 'spec_helper'

require 'realm/bus'
require 'realm/event_store'

module Realm
  module EventStore
    describe InMemoryEventStore do
      let(:event_bus) { double(EventBus, publish: nil) }
      subject(:event_store) { InMemoryEventStore.new(event_bus) }

      it "is an EventStore" do
        expect(event_store).to be_a(Realm::EventStore::EventStore)
      end

      describe "#save_events" do
        it "saves events" do
          expect {
            event_store.save_events(:uuid, [ :event_1, :event_2 ])
          }.to_not raise_error
        end

        it "publishes events" do
          event_bus.should_receive(:publish).with(:event_1)
          event_bus.should_receive(:publish).with(:event_2)

          event_store.save_events(:uuid, [ :event_1, :event_2 ])
        end
      end

      describe "#history_for_aggregate" do
        it "returns all events in order" do
          event_store.save_events(:uuid_1, [ :event_1a, :event_1b ])
          event_store.save_events(:uuid_2, [ :event_2a ])
          event_store.save_events(:uuid_1, [ :event_1c ])
          event_store.save_events(:uuid_2, [ :event_2b ])

          expect(event_store.history_for_aggregate(:uuid_1)).to be == [
            :event_1a, :event_1b, :event_1c
          ]

          expect(event_store.history_for_aggregate(:uuid_2)).to be == [
            :event_2a, :event_2b
          ]
        end

        it "raises an error if the aggregate doesn't exist" do
          expect {
            event_store.history_for_aggregate(:unknown_uuid)
          }.to raise_error(Realm::EventStore::UnknownAggregateRootError) { |error|
            expect(error.message).to include(":unknown_uuid")
          }
        end
      end
    end
  end
end
