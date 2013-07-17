require 'spec_helper'

require 'realm/messaging'
require 'realm/messaging/bus'

module Realm
  module Messaging
    module Bus
      describe SimpleMessageBus do
        # It might be better to do this with MessageTypes directly,
        # eg as in the specs for the RSpec matchers
        let(:message_factory) { Realm::Messaging::MessageFactory.new }

        before(:each) do
          message_factory.define(:message_type_1, :message_data)
          message_factory.define(:message_type_2, :message_data)
          message_factory.define(:foo)
          message_factory.define(:bar)
        end

        let(:message_handler_a) {
          double("Event Handler A", handle_message_type_1: nil)
        }
        let(:message_handler_b) {
          double("Event Handler B", handle_message_type_1: nil, handle_message_type_2: nil)
        }
        let(:message_handler_c) {
          double("Event Handler C", handle_message_type_2: nil)
        }
        subject(:message_bus) { SimpleMessageBus.new }

        it "is an MessageBus" do
          expect(message_bus).to be_a(MessageBus)
        end

        it "sends messages to registered handlers" do
          message_bus.register(:message_type_1, message_handler_a, message_handler_b)
          message_bus.register(:message_type_2, message_handler_b, message_handler_c)

          message_handler_a.should_receive(:handle_message_type_1).with(
            message_matching(message_type: :message_type_1, message_data: "foo")
          )
          message_handler_b.should_receive(:handle_message_type_1).with(
            message_matching(message_type: :message_type_1, message_data: "foo")
          )
          message_handler_b.should_receive(:handle_message_type_2).with(
            message_matching(message_type: :message_type_2, message_data: "bar")
          )
          message_handler_c.should_receive(:handle_message_type_2).with(
            message_matching(message_type: :message_type_2, message_data: "bar")
          )

          message_bus.publish(message_factory.build(:message_type_1, uuid: :unused_uuid, message_data: "foo"))
          message_bus.publish(message_factory.build(:message_type_2, uuid: :unused_uuid, message_data: "bar"))
        end

        it "sends all messages to handlers for :all_messages" do
          message_bus.register(:all_messages, message_handler_a)

          message_handler_a.should_receive(:handle_foo).with(message_matching(message_type: :foo))
          message_handler_a.should_receive(:handle_bar).with(message_matching(message_type: :bar))
          message_handler_b.should_not_receive(:handle_foo)
          message_handler_b.should_not_receive(:handle_bar)

          message_bus.publish(message_factory.build(:foo, uuid: :unused_uuid))
          message_bus.publish(message_factory.build(:bar, uuid: :unused_uuid))
        end

        it "sends unhandled messages to handlers for :unhandled_messages" do
          message_bus.register(:foo, message_handler_a)
          message_bus.register(:unhandled_message, message_handler_b)

          message_handler_a.should_receive(:handle_foo).with(message_matching(message_type: :foo))
          message_handler_a.should_not_receive(:handle_bar)

          message_handler_b.should_not_receive(:handle_unhandled_message).with(message_matching(message_type: :foo))
          message_handler_b.should_receive(:handle_unhandled_message).with(message_matching(message_type: :bar))

          message_bus.publish(message_factory.build(:foo, uuid: :unused_uuid))
          message_bus.publish(message_factory.build(:bar, uuid: :unused_uuid))
        end
      end
    end
  end
end
