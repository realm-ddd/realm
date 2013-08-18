require 'spec_helper'

require 'realm/messaging'
require 'realm/spec/matchers'

module Realm
  module Messaging
    module Bus
      describe NullResultFactory do
        describe "#new_unresolved_result" do
          let(:bus_without_result_factory) { SimpleMessageBus.new }

          it "raises an error" do
            expect {
              bus_without_result_factory.send(double(Message, system_name: nil))
            }.to raise_error(NoResultFactoryAvailableError,
              "A MessageBus must be constructed with a ResultFactory to send messages that require a response"
            )
          end
        end
      end

      describe SimpleMessageBus do
        # It might be better to do this with MessageTypes directly,
        # eg as in the specs for the RSpec matchers
        let(:message_factory) {
          Realm::Messaging::MessageFactory.new do |messages|
            messages.define(:message_type_1, properties: { message_data: String })
            messages.define(:message_type_2, properties: { message_data: String })
            messages.define(:foo)
            messages.define(:bar)
          end
        }

        let(:message_handler_a) {
          double("Message Handler A", handle_message_type_1: nil)
        }
        let(:message_handler_b) {
          double("Message Handler B", handle_message_type_1: nil, handle_message_type_2: nil)
        }
        let(:message_handler_c) {
          double("Message Handler C", handle_message_type_2: nil)
        }

        # The next three exist only for #send, not #publish
        let(:result_factory) { double(ResultFactory, new_unresolved_result: result) }
        let(:result) { double(Result) }
        let(:unhandled_send_handler) {
          double("Unhanded send message handler", handle_unhandled_message: nil)
        }

        subject(:message_bus) {
          SimpleMessageBus.new(
            result_factory:         result_factory,
            unhandled_send_handler: unhandled_send_handler
          )
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

        describe "#route_messages_for_subsystem" do
          let(:subsystem_message) {
            double(Message, system_name: :other_system, message_type_name: :message_type_1)
          }

          let(:downstream_message_bus) { double(MessageBus, publish: nil, send: nil) }

          before(:each) do
            message_bus.register(:message_type_1, message_handler_a)
            message_bus.route_messages_for_subsystem(:other_system, to_message_bus: downstream_message_bus)
          end

          describe "with #publish" do
            it "causes messages for a subsystem to be sent to the nominated bus" do
              message_bus.publish(subsystem_message)
              expect(downstream_message_bus).to have_received(:publish).with(subsystem_message)
            end

            it "doesn't publish to handlers on this bus" do
              message_bus.publish(subsystem_message)
              expect(message_handler_a).to_not have_received(:handle_message_type_1)
            end
          end

          describe "with #send" do
            it "causes messages for a subsystem to be sent to the nominated bus" do
              message_bus.send(subsystem_message)
              expect(downstream_message_bus).to have_received(:send).with(subsystem_message)
            end

            it "doesn't send to handlers on this bus" do
              message_bus.send(subsystem_message)
              expect(message_handler_a).to_not have_received(:handle_message_type_1)
            end
          end
        end

        describe "#publish" do
          it "sends messages to registered handlers" do
            message_bus.register(:message_type_1, message_handler_a, message_handler_b)
            message_bus.register(:message_type_2, message_handler_b, message_handler_c)

            message_handler_a.should_receive(:handle_message_type_1).with(
              message_matching(message_type_name: :message_type_1, message_data: "foo")
            )
            message_handler_b.should_receive(:handle_message_type_1).with(
              message_matching(message_type_name: :message_type_1, message_data: "foo")
            )
            message_handler_b.should_receive(:handle_message_type_2).with(
              message_matching(message_type_name: :message_type_2, message_data: "bar")
            )
            message_handler_c.should_receive(:handle_message_type_2).with(
              message_matching(message_type_name: :message_type_2, message_data: "bar")
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

            message_handler_a.should_receive(:handle_foo).with(message_matching(message_type_name: :foo))
            message_handler_a.should_receive(:handle_bar).with(message_matching(message_type_name: :bar))
            message_handler_b.should_not_receive(:handle_foo)
            message_handler_b.should_not_receive(:handle_bar)

            message_bus.publish(message_factory.build(:foo))
            message_bus.publish(message_factory.build(:bar))
          end

          it "sends unhandled messages to handlers for :unhandled_messages" do
            message_bus.register(:foo, message_handler_a)
            message_bus.register(:unhandled_message, message_handler_b)

            message_handler_a.should_receive(:handle_foo).with(message_matching(message_type_name: :foo))
            message_handler_a.should_not_receive(:handle_bar)

            message_handler_b.should_not_receive(:handle_unhandled_message).with(message_matching(message_type_name: :foo))
            message_handler_b.should_receive(:handle_unhandled_message).with(message_matching(message_type_name: :bar))

            message_bus.publish(message_factory.build(:foo))
            message_bus.publish(message_factory.build(:bar))
          end

          context "with an actor handler" do
            let(:async_proxy) { double("async proxy", handle_foo: nil) }
            let(:actor_handler) { double("Actor Message Handler", async: async_proxy) }

            before(:each) do
              message_bus.register(:foo, actor_handler)
            end

            it "publishes asynchronously" do
              message_bus.publish(message_factory.build(:foo))
              expect(async_proxy).to have_received(:handle_foo).with(message_matching(message_type_name: :foo))
            end
          end
        end

        describe "#send" do
          let(:fake_message) { double("Message", system_name: nil, message_type_name: :fake_message) }

          it "constructs a result" do
            message_bus.send(fake_message)
            expect(result_factory).to have_received(:new_unresolved_result).with(fake_message)
          end

          it "returns the result" do
            message_bus.register(:message_type_1, message_handler_a)

            expect(
              message_bus.send(
                message_factory.build(:message_type_1, message_data: "foo")
              )
            ).to be(result)
          end

          it "sends messages to the one registered handler" do
            message_bus.register(:message_type_1, message_handler_a)

            message_handler_a.should_receive(:handle_message_type_1).with(
              message_matching(message_type_name: :message_type_1, message_data: "foo"),
              response_port: result
            )

            message_bus.send(
              message_factory.build(:message_type_1, message_data: "foo")
            )
          end

          # It only makes sense to send the response port to explicit handlers, as we expect
          # only one of them. This makes the code here a bit hacky, but fortunately at least
          # simplifies the MessageLogger which therefore doesn't neet to worry about it.
          it "sends all messages to handlers for :all_messages, not the response port" do
            message_bus.register(:all_messages, message_handler_a)

            message_handler_a.should_receive(:handle_foo).with(
              message_matching(message_type_name: :foo)
            )
            message_handler_a.should_receive(:handle_bar).with(
              message_matching(message_type_name: :bar)
            )
            message_handler_b.should_not_receive(:handle_foo)
            message_handler_b.should_not_receive(:handle_bar)

            message_bus.send(message_factory.build(:foo))
            message_bus.send(message_factory.build(:bar))
          end

          it "raises an error if it finds more than one handler" do
            message_bus.register(:foo, message_handler_a, message_handler_b)

            expect {
              message_bus.send(message_factory.build(:foo))
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
                message_factory.build(:message_type_1, message_data: :unimportant)
              )
            rescue SimpleMessageBus::TooManyMessageHandlersError => error
              expect(error).to be_nil
            end
          end

          it "sends unhandled messages to the specified handler" do
            message_bus.register(:foo, message_handler_a)

            message_handler_a.should_not_receive(:handle_unhandled_message)
            unhandled_send_handler.should_receive(:handle_unhandled_message).with(message_matching(message_type_name: :bar))

            message_bus.send(message_factory.build(:bar))
          end

          context "with an actor handler" do
            let(:async_proxy) { double("async proxy", handle_foo: nil) }
            let(:actor_handler) { double("Actor Message Handler", async: async_proxy) }

            before(:each) do
              message_bus.register(:foo, actor_handler)
            end

            it "publishes asynchronously" do
              message_bus.send(message_factory.build(:foo))
              expect(async_proxy).to have_received(:handle_foo).with(
                message_matching(message_type_name: :foo),
                response_port: result
              )
            end
          end

          # This is a very roundabout way of proving we pass the response port (result) to the handler
          context "a response port" do
            before(:each) do
              result.stub(message_handled: nil)
            end

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
                message_factory.build(:message_type_1, message_data: "some data")
              )

              expect(result).to have_received(:message_handled).with("I got some data")
            end
          end

          context "with an actor handler" do
            let(:async_proxy) { double("async proxy", handle_foo: nil) }
            let(:actor_handler) { double("Actor Message Handler", async: async_proxy) }

            before(:each) do
              message_bus.register(:foo, actor_handler)
            end

            it "publishes asynchronously" do
              pending "redo this from #publish to #send"
              message_bus.publish(message_factory.build(:foo))
              expect(async_proxy).to have_received(:handle_foo).with(message_matching(message_type_name: :foo))
            end
          end
        end

        it "has tests for `abort`" do
          pending
        end
      end
    end
  end
end
