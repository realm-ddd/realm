require 'spec_helper'

require 'realm/bus'

module Realm
  module Bus
    describe SimpleEventBus do
      # It might be better to do this with EventTypes directly,
      # eg as in the specs for the RSpec matchers
      let(:event_factory) { Realm::Domain::EventFactory.new }

      before(:each) do
        event_factory.define(:event_type_1, :message_data)
        event_factory.define(:event_type_2, :message_data)
        event_factory.define(:foo)
        event_factory.define(:bar)
      end

      let(:event_handler_a) {
        double("Event Handler A", handle_event_type_1: nil)
      }
      let(:event_handler_b) {
        double("Event Handler B", handle_event_type_1: nil, handle_event_type_2: nil)
      }
      let(:event_handler_c) {
        double("Event Handler C", handle_event_type_2: nil)
      }
      subject(:event_bus) { SimpleEventBus.new }

      it "is an EventBus" do
        expect(event_bus).to be_an(EventBus)
      end

      it "sends events to registered handlers" do
        event_bus.register(:event_type_1, event_handler_a, event_handler_b)
        event_bus.register(:event_type_2, event_handler_b, event_handler_c)

        event_handler_a.should_receive(:handle_event_type_1).with(
          event_matching(event_type: :event_type_1, message_data: "foo")
        )
        event_handler_b.should_receive(:handle_event_type_1).with(
          event_matching(event_type: :event_type_1, message_data: "foo")
        )
        event_handler_b.should_receive(:handle_event_type_2).with(
          event_matching(event_type: :event_type_2, message_data: "bar")
        )
        event_handler_c.should_receive(:handle_event_type_2).with(
          event_matching(event_type: :event_type_2, message_data: "bar")
        )

        event_bus.publish(event_factory.build(:event_type_1, uuid: :unused_uuid, message_data: "foo"))
        event_bus.publish(event_factory.build(:event_type_2, uuid: :unused_uuid, message_data: "bar"))
      end

      it "sends all events to handlers for :all_events" do
        event_bus.register(:all_events, event_handler_a)

        event_handler_a.should_receive(:handle_foo).with(event_matching(event_type: :foo))
        event_handler_a.should_receive(:handle_bar).with(event_matching(event_type: :bar))
        event_handler_b.should_not_receive(:handle_foo)
        event_handler_b.should_not_receive(:handle_bar)

        event_bus.publish(event_factory.build(:foo, uuid: :unused_uuid))
        event_bus.publish(event_factory.build(:bar, uuid: :unused_uuid))
      end

      it "sends unhandled events to handlers for :unhandled_events" do
        event_bus.register(:foo, event_handler_a)
        event_bus.register(:unhandled_event, event_handler_b)

        event_handler_a.should_receive(:handle_foo).with(event_matching(event_type: :foo))
        event_handler_a.should_not_receive(:handle_bar)

        event_handler_b.should_not_receive(:handle_unhandled_event).with(event_matching(event_type: :foo))
        event_handler_b.should_receive(:handle_unhandled_event).with(event_matching(event_type: :bar))

        event_bus.publish(event_factory.build(:foo, uuid: :unused_uuid))
        event_bus.publish(event_factory.build(:bar, uuid: :unused_uuid))
      end
    end
  end
end
