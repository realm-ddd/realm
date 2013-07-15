require 'spec_helper'

require 'realm/domain/event_factory'

module Realm
  module Domain
    class EventFactory
      describe EventFactory::EventType do
        subject(:event_type) { EventType.new(:test_event_type, [:property_1, :property_2]) }

        it "can be built with no properties" do
          # RSpec 2.14 deprecation:
          # DEPRECATION: `expect { }.not_to raise_error(SpecificErrorClass)` is deprecated. Use `expect { }.not_to raise_error()` instead
          begin
            EventType.new(:empty_event_type)
          rescue ArgumentError
            fail "We must be able to construct empty events with no extra arguments"
          rescue StandardError
            # We don't care about anything other errors for the purposes of this example
          end
        end

        describe "#new_event" do
          context "providing missing/superflous attributes" do
            it "includes all relevant details when building the error" do
              expect {
                event_type.new_event(uuid: :sample_uuid, property_1: "attribute 1", property_4: "attribute 4")
              }.to raise_error(EventFactory::EventPropertyError) { |error|
                expect(error.message).to include("test_event_type", "property_2", "property_4")
              }
            end
          end

          describe "a built Event" do
            let(:event) {
              event_type.new_event(uuid: :sample_uuid, property_1: "attribute 1", property_2: "attribute 2")
            }

            it "has a timestamp" do
              expect(event.timestamp).to be_within(1).of(Time.now)
            end

            it "lets you override the timestamp" do
              event = event_type.new_event(
                uuid: :sample_uuid, property_1: "attribute 1", property_2: "attribute 2",
                timestamp: :overridden_timestamp
              )
              expect(event.timestamp).to be == :overridden_timestamp
            end

            it "has a hard-coded version" do
              expect(event.version).to be == 1
            end

            it "has all properties" do
              expect(event.property_1).to be == "attribute 1"
              expect(event.property_2).to be == "attribute 2"
            end
          end
        end
      end
    end
  end
end

