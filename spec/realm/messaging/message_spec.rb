require 'spec_helper'

require 'realm/messaging/message'

module Realm
  module Messaging
    describe Message do
      subject(:message) {
        Message.new(test_message_attributes)
      }

      # Not using let to guarantee we get a new object each time
      def test_message_attributes
        {
          message_type_name: :test_message_type_name,
          version: 1,
          timestamp: :test_timestamp,
          uuid: :test_uuid,
          property_1: "attribute 1",
          property_2: nil
        }
      end

      its(:to_s) {
        # Note use of inspect
        should include(
          "Message",
          "version",
          "1",
          "timestamp",
          ":test_timestamp",
          "test_message_type_name",
          "property_1:",
          "attribute 1",
          "property_2:",
          "nil"
        )
      }

      its(:message_type_name)  { should be == :test_message_type_name }
      its(:version)     { should be == 1 }
      its(:timestamp)   { should be == :test_timestamp }
      its(:uuid)        { should be == :test_uuid }

      describe "#system_name" do
        example do
          expect(
            Message.new(test_message_attributes, system_name: :other_system).system_name
          ).to be == :other_system
        end
      end

      describe "#output_to" do
        let(:formatter) { double("MessageFormatter", format: "formatted_message") }

        it "formats with the formatted" do
          message.output_to(formatter)
          expect(formatter).to have_received(:format).with(
            category:   :message,
            type:       :test_message_type_name,
            version:    1,
            timestamp:  :test_timestamp,
            attributes: {
              uuid:       :test_uuid,
              property_1: "attribute 1",
              property_2: nil
            }
          )
        end

        it "returns the formatted value" do
          expect(message.output_to(formatter)).to be == "formatted_message"
        end
      end

      describe "properties" do
        context "message_type_name" do
          def test_message_attributes
            super.merge(message_type_name: "string_converted_to_symbol")
          end

          it "always returns message_type_name as a symbol" do
            expect(message.message_type_name).to be == :string_converted_to_symbol
          end
        end

        describe "attribute access" do
          it "gives access to all attributes" do
            expect(message.property_1).to be == "attribute 1"
            expect(message.property_2).to be_nil
          end

          it "raises an NoMethodError when the attribute is missing" do
            expect {
              message.unknown_property
            }.to raise_error(NoMethodError) { |error|
              expect(error.message).to include("unknown_property")
            }
          end

          specify "#respond_to?(<property>)" do
            %i[ message_type_name uuid version timestamp property_1 property_2 ].each do |property|
              expect(message).to respond_to(property)
            end
          end

          specify "#respond_to?(<normal method>)" do
            expect(message).to respond_to(:to_s)
          end
        end
      end

      describe "#matches?" do
        it "is true if everything is the same" do
          expect(message).to match_message_description(test_message_attributes)
        end

        it "is false if the message type is different" do
          expect(message).to_not match_message_description(
            test_message_attributes.merge(message_type_name: :wrong_message_type_name)
          )
        end

        it "raises an error if you don't provide an message type" do
          expect {
            message.matches?({ })
          }.to raise_error(ArgumentError) { |error|
            expect(error.message).to include("message_type_name")
          }
        end

        it "is false if the version is different" do
          expect(message).to_not match_message_description(
            test_message_attributes.merge(version: :wrong_version)
          )
        end

        it "is true if a version is not given" do
          expect(message).to match_message_description(
            test_message_attributes - [ :version ]
          )
        end

        it "is still true if the timestamp is different" do
          expect(message).to match_message_description(
            test_message_attributes.merge(timestamp: :wrong_timestamp)
          )
        end

        it "is false if a uuid is given but is different" do
          expect(message).to_not match_message_description(
            test_message_attributes.merge(uuid: :wrong_uuid)
          )
        end

        it "is true if a uuid is not given" do
          expect(message).to match_message_description(
            test_message_attributes - [ :uuid ]
          )
        end

        it "is false if an attribute is different" do
          expect(message).to_not match_message_description(
            test_message_attributes.merge(property_2: :wrong_attribute)
          )
        end

        it "is false if an attribute is missing" do
          expect(message).to_not match_message_description(
            test_message_attributes - [ :property_2 ]
          )
        end

        context "an unknown property is given" do
          it "raises an error for the same message type" do
            expect {
              message.matches?(
                test_message_attributes.merge(
                  unknown_property_1: :superfluous_attribute,
                  unknown_property_2: :superfluous_attribute
                )
              )
            }.to raise_error(ArgumentError) { |error|
              expect(error.message).to include("Unknown Message properties", "unknown_property_1", "unknown_property_2")
            }
          end

          it "is just false for a different message type" do
            expect(message).to_not match_message_description(
              test_message_attributes.merge(
                message_type_name: :other_message_type_name,
                unknown_property:  :superfluous_attribute
              )
            )
          end
        end
      end
    end
  end
end