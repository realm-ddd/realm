require 'spec_helper'

require 'realm/messaging'

module Realm
  module Messaging
    module Bus
      describe SimpleMessageBus do
        # It might be better to do this with MessageTypes directly,
        # eg as in the specs for the RSpec matchers
        let(:message_factory) {
          Realm::Messaging::MessageFactory.new
        }

        before(:each) do
          message_factory.define(:message_type_1, :message_data)
          message_factory.define(:message_type_2, :message_data)
          message_factory.define(:foo)
          message_factory.define(:bar)
        end

        let(:message_handler_a) {
          double("Message Handler A", handle_message_type_1: nil)
        }
        let(:message_handler_b) {
          double("Message Handler B", handle_message_type_1: nil, handle_message_type_2: nil)
        }
        let(:message_handler_c) {
          double("Message Handler C", handle_message_type_2: nil)
        }
        let(:unhandled_send_handler) {
          double("Unhanded send message handler", handle_unhandled_message: nil)
        }

        let(:null_response_port) { double("Null Response Port").as_null_object }

        subject(:message_bus) {
          SimpleMessageBus.new(unhandled_send_handler: unhandled_send_handler)
        }

        it "is an MessageBus" do
          expect(message_bus).to be_a(MessageBus)
        end

        describe "#register" do
          it "returns the bus (for chanining)" do
            expect(
              message_bus.register(:message_type_1, message_handler_a)
            ).to equal(message_bus)
          end
        end

        describe "#publish" do
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

            message_bus.publish(message_factory.build(:message_type_1, message_data: "foo"))
            message_bus.publish(message_factory.build(:message_type_2, message_data: "bar"))
          end

          it "returns nil" do
            expect(
              message_bus.publish(message_factory.build(:message_type_1, message_data: "foo"))
            ).to be_nil
          end

          it "sends all messages to handlers for :all_messages" do
            message_bus.register(:all_messages, message_handler_a)

            message_handler_a.should_receive(:handle_foo).with(message_matching(message_type: :foo))
            message_handler_a.should_receive(:handle_bar).with(message_matching(message_type: :bar))
            message_handler_b.should_not_receive(:handle_foo)
            message_handler_b.should_not_receive(:handle_bar)

            message_bus.publish(message_factory.build(:foo))
            message_bus.publish(message_factory.build(:bar))
          end

          it "sends unhandled messages to handlers for :unhandled_messages" do
            message_bus.register(:foo, message_handler_a)
            message_bus.register(:unhandled_message, message_handler_b)

            message_handler_a.should_receive(:handle_foo).with(message_matching(message_type: :foo))
            message_handler_a.should_not_receive(:handle_bar)

            message_handler_b.should_not_receive(:handle_unhandled_message).with(message_matching(message_type: :foo))
            message_handler_b.should_receive(:handle_unhandled_message).with(message_matching(message_type: :bar))

            message_bus.publish(message_factory.build(:foo))
            message_bus.publish(message_factory.build(:bar))
          end
        end

        describe "#send" do
          it "returns nil" do
            message_bus.register(:message_type_1, message_handler_a)

            expect(
              message_bus.send(
                message_factory.build(:message_type_1, message_data: "foo"),
                response_port: null_response_port
              )
            ).to be_nil
          end

          it "sends messages to the one registered handler" do
            message_bus.register(:message_type_1, message_handler_a)

            message_handler_a.should_receive(:handle_message_type_1).with(
              message_matching(message_type: :message_type_1, message_data: "foo"),
              response_port: null_response_port
            )

            message_bus.send(
              message_factory.build(:message_type_1, message_data: "foo"),
              response_port: null_response_port
            )
          end

          # It only makes sense to send the response port to explicit handlers, as we expect
          # only one of them. This makes the code here a bit hacky, but fortunately at least
          # simplifies the MessageLogger which therefore doesn't neet to worry about it.
          it "sends all messages to handlers for :all_messages, not the response port" do
            message_bus.register(:all_messages, message_handler_a)

            message_handler_a.should_receive(:handle_foo).with(
              message_matching(message_type: :foo)
            )
            message_handler_a.should_receive(:handle_bar).with(
              message_matching(message_type: :bar)
            )
            message_handler_b.should_not_receive(:handle_foo)
            message_handler_b.should_not_receive(:handle_bar)

            message_bus.send(message_factory.build(:foo), response_port: null_response_port)
            message_bus.send(message_factory.build(:bar), response_port: null_response_port)
          end

          it "raises an error if it finds more than one handler" do
            message_bus.register(:foo, message_handler_a, message_handler_b)

            expect {
              message_bus.send(
                message_factory.build(:foo),
                response_port: null_response_port
              )
            }.to raise_error(
              SimpleMessageBus::TooManyMessageHandlersError,
              /Found 2 message handlers for "foo":.*Message Handler A.*Message Handler B/
            )
          end

          it "doesn't count an :all_messages handler towards the handler count" do
            message_bus.register(:message_type_1, message_handler_a)
            message_bus.register(:all_messages, message_handler_b)

            begin
              message_bus.send(
                message_factory.build(:message_type_1, message_data: :unimportant),
                response_port: null_response_port
              )
            rescue SimpleMessageBus::TooManyMessageHandlersError => error
              expect(error).to be_nil
            end
          end

          it "sends unhandled messages to the specified handler" do
            message_bus.register(:foo, message_handler_a)

            message_handler_a.should_not_receive(:handle_unhandled_message)
            unhandled_send_handler.should_receive(:handle_unhandled_message).with(message_matching(message_type: :bar))

            message_bus.send(message_factory.build(:bar), response_port: null_response_port)
          end

          context "a response port" do
            let(:response_port) {
              double("Response Port", message_handled: nil)
            }

            before(:each) do
              # We have to use a hash (dependencies) here because Ruby 2 blocks
              # don't yet support keyword args
              message_handler_a.stub(:handle_message_type_1) do |message, dependencies|
                dependencies.fetch(:response_port).message_handled("I got #{message.message_data}")
              end
            end

            it "lets you specify a response port" do
              message_bus.register(:message_type_1, message_handler_a)

              message_bus.send(
                message_factory.build(:message_type_1, message_data: "some data"),
                response_port: response_port
              )

              expect(response_port).to have_received(:message_handled).with("I got some data")
            end
          end
        end
      end
    end
  end
end
