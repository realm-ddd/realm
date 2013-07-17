require 'spec_helper'

require 'realm/messaging'

module Realm
  module Messaging
    describe MessageFactory do
      let(:message_type) { double(MessageType) }
      let(:message_type_factory) { double("MessageTypeFactory", new: message_type) } # Unnamed type
      subject(:message_factory) { MessageFactory.new(message_type_factory) }

      describe "#define" do
        it "builds the MessageType" do
          message_type_factory.should_receive(:new).with(:message_type_name, [:property_1, :property_2])
          message_factory.define(:message_type_name, :property_1, :property_2)
        end
      end

      describe "#build" do
        context "MessageType is defined" do
          before(:each) do
            message_factory.define(:message_type_name, :property_1, :property_2)
          end

          it "tells the MessageType to build an message" do
            message_type.should_receive(:new_message).with(
              property_1: "attribute 1", property_2: "attribute 2"
            )
            message_factory.build(
              :message_type_name, property_1: "attribute 1", property_2: "attribute 2"
            )
          end
        end

        context "MessageType is not defined" do
          it "raises an error" do
            expect {
              message_factory.build(:unknown_message_type_name)
            }.to raise_error(MessageFactory::UnknownMessageTypeError) { |error|
              expect(error.message).to include("unknown_message_type_name")
            }
          end
        end
      end
    end
  end
end
