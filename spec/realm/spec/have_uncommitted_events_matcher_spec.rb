require 'spec_helper'

require 'realm/domain'
require 'realm/spec'

describe "expect(aggregate_root).to have_uncommitted_events(...)" do
  let(:event_factory) { Realm::Domain::EventFactory.new }

  subject(:aggregate_root) {
    double(
      Realm::Domain::AggregateRoot,
      uuid: :aggregate_uuid, uncommitted_events: uncommitted_events
    )
  }

  let(:matcher) { have_no_uncommitted_events }

  before(:each) do
    event_factory.define(:this_happened, :property_1, :property_2)
    event_factory.define(:that_happened, :property_a, :property_b)
  end

  context "no events" do
    let(:uncommitted_events) { [ ] }

    specify {
      expect(
        have_no_uncommitted_events.matches?(aggregate_root)
      ).to be_true
    }
  end

  context "events" do
    let(:uncommitted_events) {
      [
        event_factory.build(:this_happened, uuid: :aggregate_uuid, property_1: "one", property_2: "two"),
        event_factory.build(:this_happened, uuid: :aggregate_uuid, property_1: "ein", property_2: "zwei"),
        event_factory.build(:that_happened, uuid: :aggregate_uuid, property_a: "x", property_b: "y")
      ]
    }

    context "expecting no events" do
      it "does not match" do
        expect(
          matcher.matches?(aggregate_root)
        ).to be_false
      end

      specify "error message mentions all uncommitted events" do
        matcher.matches?(aggregate_root)
        expect(
          matcher.failure_message_for_should
        ).to include("this_happened", "that_happened", "one", "ein", "x")
      end
    end

    context "expecting events" do
      context "events not in the uncommitted list" do
        it "does not match" do
          expect(
            matcher.matches?(aggregate_root)
          ).to be_false
        end

        specify "error message mentions all uncommitted events" do
          matcher.matches?(aggregate_root)
          expect(
            matcher.failure_message_for_should
          ).to include("this_happened", "that_happened", "one", "ein", "x")
        end
      end

      context "specified uncommitted events that does not match" do
        let(:matcher) {
          have_uncommitted_events(
            { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "wrong value", property_2: "two"   }
          )
        }

        it "does not match" do
          expect(
            matcher.matches?(aggregate_root)
          ).to be_false
        end

        specify "error message" do
          matcher.matches?(aggregate_root)
          expect(
            matcher.failure_message_for_should
          ).to include("this_happened", "property_1", "wrong value")
        end
      end

      context "specified uncommitted event that does match" do
        let(:matcher) {
          have_uncommitted_events(
            { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "ein", property_2: "zwei"  }
          )
        }

        it "matches" do
          expect(
            matcher.matches?(aggregate_root)
          ).to be_true
        end
      end

      context "multiple events" do
        context "that match" do
          let(:matcher) {
            have_uncommitted_events(
              { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "one", property_2: "two"   },
              { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "ein", property_2: "zwei"  },
              { event_type: :that_happened, uuid: :aggregate_uuid, property_a: "x",   property_b: "y"     }
            )
          }

          it "matches" do
            expect(
              matcher.matches?(aggregate_root)
            ).to be_true
          end
        end

        context "that don't match" do
          let(:matcher) {
            have_uncommitted_events(
              { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "one", property_2: "two"   },
              { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "ein", property_2: "zwei"  },
              { event_type: :that_happened, uuid: :aggregate_uuid, property_a: "x",   property_b: "z"     }
            )
          }

          it "does not match" do
            expect(
              matcher.matches?(aggregate_root)
            ).to be_false
          end

          specify "error message includes non-matching events" do
            matcher.matches?(aggregate_root)
            expect(
              matcher.failure_message_for_should
            ).to include("that_happened", "property_b", "z")
          end
        end
      end
    end
  end
end