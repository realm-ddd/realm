require 'spec_helper'

require 'realm/domain/event_factory'

module Realm
  module Domain
    class EventFactory
      describe Event do
        subject(:event) {
          Event.new(test_event_attributes)
        }

        # Not using let to guarantee we get a new object each time
        def test_event_attributes
          {
            event_type: :test_event_type,
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
            "Event",
            "version",
            "1",
            "timestamp",
            ":test_timestamp",
            "test_event_type",
            "property_1:",
            "attribute 1",
            "property_2:",
            "nil"
          )
        }

        its(:event_type)  { should be == :test_event_type }
        its(:version)     { should be == 1 }
        its(:timestamp)   { should be == :test_timestamp }
        its(:uuid)        { should be == :test_uuid }

        describe "properties" do
          context "event_type" do
            def test_event_attributes
              super.merge(event_type: "string_converted_to_symbol")
            end

            it "always returns event_type as a symbol" do
              expect(event.event_type).to be == :string_converted_to_symbol
            end
          end

          describe "attribute access" do
            it "gives access to all attributes" do
              expect(event.property_1).to be == "attribute 1"
              expect(event.property_2).to be_nil
            end

            it "raises an NoMethodError when the attribute is missing" do
              expect {
                event.unknown_property
              }.to raise_error(NoMethodError) { |error|
                expect(error.message).to include("unknown_property")
              }
            end
          end
        end

        describe "#matches?" do
          it "is true if everything is the same" do
            expect(event).to match_event_description(test_event_attributes)
          end

          it "is false if the event type is different" do
            expect(event).to_not match_event_description(
              test_event_attributes.merge(event_type: :wrong_event_type)
            )
          end

          it "raises an error if you don't provide an event type" do
            expect {
              event.matches?({ })
            }.to raise_error(ArgumentError) { |error|
              expect(error.message).to include("event_type")
            }
          end

          it "is false if the version is different" do
            expect(event).to_not match_event_description(
              test_event_attributes.merge(version: :wrong_version)
            )
          end

          it "is true if a version is not given" do
            expect(event).to match_event_description(
              test_event_attributes - [ :version ]
            )
          end

          it "is still true if the timestamp is different" do
            expect(event).to match_event_description(
              test_event_attributes.merge(timestamp: :wrong_timestamp)
            )
          end

          it "is false if a uuid is given but is different" do
            expect(event).to_not match_event_description(
              test_event_attributes.merge(uuid: :wrong_uuid)
            )
          end

          it "is true if a uuid is not given" do
            expect(event).to match_event_description(
              test_event_attributes - [ :uuid ]
            )
          end

          it "is false if an attribute is different" do
            expect(event).to_not match_event_description(
              test_event_attributes.merge(property_2: :wrong_attribute)
            )
          end

          it "is false if an attribute is missing" do
            expect(event).to_not match_event_description(
              test_event_attributes - [ :property_2 ]
            )
          end

          context "an unknown property is given" do
            it "raises an error for the same event type" do
              expect {
                event.matches?(
                  test_event_attributes.merge(
                    unknown_property_1: :superfluous_attribute,
                    unknown_property_2: :superfluous_attribute
                  )
                )
              }.to raise_error(ArgumentError) { |error|
                expect(error.message).to include("Unknown Event properties", "unknown_property_1", "unknown_property_2")
              }
            end

            it "is just false for a different event type" do
              expect(event).to_not match_event_description(
                test_event_attributes.merge(
                  event_type: :other_event_type,
                  unknown_property: :superfluous_attribute
                )
              )
            end
          end
        end
      end
    end
  end
end