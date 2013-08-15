require 'spec_helper'

require 'realm/messaging'

module Realm
  module Messaging
    describe MessageFactory do
      let(:message_type) { double(MessageType) }
      let(:message_type_factory) { double("MessageTypeFactory", new: message_type) } # Unnamed type
      subject(:message_factory) { MessageFactory.new(message_type_factory) }

      describe ".new" do
        let(:block_factory) {
          MessageFactory.new do |messages|
            messages.define(:my_message_type, properties: { only_property: String })
          end
        }

        example "with a block" do
          expect(
            block_factory.build(:my_message_type, only_property: "foo")
          ).to match_message_description(message_type_name: :my_message_type, only_property: "foo")
        end
      end

      describe "#define" do
        context "properties" do
          it "builds the MessageType" do
            message_type_factory.should_receive(:new).with(
              :message_type_name, properties: { property_1: String, property_2: String }
            )
            message_factory.define(:message_type_name, properties: { property_1: String, property_2: String })
          end
        end

        context "no properties" do
          it "builds the MessageType" do
            begin
              message_factory.define(:message_type_name)
            rescue ArgumentError
              fail "We must be able to define empty message types with no extra arguments"
            rescue StandardError

            end
          end
        end

        context "responses" do
          it "builds the MessageType" do
            message_factory.define(:message_type_name,
              responses: [ :response_message_name_1, :response_message_name_2 ]
            )

            expect(message_type_factory).to have_received(:new).with(
              :message_type_name, responses: [ :response_message_name_1, :response_message_name_2 ]
            )
          end
        end
      end

      describe "#build" do
        context "MessageType is defined" do
          before(:each) do
            message_factory.define(:message_type_name, properties: { property_1: String, property_2: String })
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
            }.to raise_error(UnknownMessageTypeError) { |error|
              expect(error.message).to include("unknown_message_type_name")
            }
          end
        end
      end

      describe "#determine_responses_to" do
        let(:message_factory_1) {
          MessageFactory.new do |messages|
            messages.define(:do_this,
              responses: [ :this_happened, :that_happened ]
            )
            messages.define(:do_something_else,
              responses: [ :the_other_happened ]
            )
          end
        }

        let(:message_factory_2) {
          MessageFactory.new do |messages|
            messages.define(:this_happened)
            messages.define(:that_happened)
            messages.define(:_unused_outcome_)
          end
        }

        context "originating message type is known" do
          let(:determined_responses) {
            message_factory_1.determine_responses_to(:do_this, from: message_factory_2)
          }

          specify {
            expect(determined_responses.keys.sort).to be == [ :that_happened, :this_happened ]
            expect(determined_responses[:this_happened].name).to be == :this_happened
            expect(determined_responses[:that_happened].name).to be == :that_happened
          }
        end

        context "originating message type is unknown" do
          it "raises an error" do
            expect {
              message_factory_1.determine_responses_to(:i_dont_know_how_to_do_this, from: message_factory_2)
            }.to raise_error(UnknownMessageTypeError, /i_dont_know_how_to_do_this/)
          end
        end
      end

      describe "#select_message_types" do
        subject(:message_factory) {
          MessageFactory.new do |messages|
            messages.define(:this_happened)
            messages.define(:that_happened)
            messages.define(:the_other_happened)
          end
        }

        example do
          expect(
            message_factory.select_message_types { |type|
              type.name.to_s =~ /this|other/
            }.keys.sort
          ).to be == [ :the_other_happened, :this_happened ]
        end
      end
    end
  end
end
