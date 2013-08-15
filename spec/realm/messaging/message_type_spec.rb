require 'spec_helper'

require 'realm/messaging/message_factory'

module Realm
  module Messaging
    describe MessageType do
      subject(:message_type) {
        MessageType.new(:test_message_type,
          properties: { property_1: String, property_2: String },
          responses: [ :response_message_name_1, :response_message_name_2 ]
        )
      }

      its(:name) { should be == :test_message_type }

      it "can be built with no properties" do
        # RSpec 2.14 deprecation:
        # DEPRECATION: `expect { }.not_to raise_error(SpecificErrorClass)` is deprecated. Use `expect { }.not_to raise_error()` instead
        begin
          MessageType.new(:empty_message_type)
        rescue ArgumentError
          fail "We must be able to construct empty messages with no extra arguments"
        rescue StandardError
          # We don't care about anything other errors for the purposes of this example
        end
      end

      describe "#new_message" do
        context "providing missing/superflous attributes" do
          it "includes all relevant details when building the error" do
            expect {
              message_type.new_message(property_1: "attribute 1", property_4: "attribute 4")
            }.to raise_error(MessagePropertyError) { |error|
              expect(error.message).to include("test_message_type", "property_2", "property_4")
            }
          end
        end

        describe "a built Message" do
          let(:message) {
            message_type.new_message(property_1: "attribute 1", property_2: "attribute 2")
          }

          it "has a timestamp" do
            expect(message.timestamp).to be_within(1).of(Time.now)
          end

          it "lets you override the timestamp" do
            message = message_type.new_message(
              property_1: "attribute 1", property_2: "attribute 2",
              timestamp: :overridden_timestamp
            )
            expect(message.timestamp).to be == :overridden_timestamp
          end

          it "has a hard-coded version" do
            expect(message.version).to be == 1
          end

          it "has all properties" do
            expect(message.property_1).to be == "attribute 1"
            expect(message.property_2).to be == "attribute 2"
          end
        end
      end

      describe "#response_to?" do
        let(:target) { double(MessageType, accept_as_response?: accept_as_response?) }

        context "target accepts this as a response" do
          let(:accept_as_response?) { true }

          specify {
            message_type.response_to?(target)
            expect(target).to have_received(:accept_as_response?).with(:test_message_type)
          }

          specify {
            expect(message_type).to be_response_to(target)
          }
        end

        context "target doesn't accept this as a response" do
          let(:accept_as_response?) { false }

          specify {
            message_type.response_to?(target)
            expect(target).to have_received(:accept_as_response?).with(:test_message_type)
          }

          specify {
            expect(message_type).to_not be_response_to(target)
          }
        end
      end

      describe "#accept_as_response?" do
        context "given message name is a known response" do
          specify {
            expect(
              message_type.accept_as_response?(:response_message_name_1)
            ).to be_true
          }
        end

        context "given message name is not a known response" do
          specify {
            expect(
              message_type.accept_as_response?(:unknown_message_name)
            ).to be_false
          }
        end
      end
    end
  end
end

