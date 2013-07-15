require 'spec_helper'

require 'realm/domain'

module Realm
  module Domain
    describe AggregateRoot do
      class TestAggregateRoot
        extend Realm::Domain::AggregateRoot

        Events = EventFactory.new
        Events.define(:test_aggregate_created, :foo)
        Events.define(:foo_updated, :foo)
        Events.define(:simple_event)

        # This is a violation of CQRS, don't attach getters to real
        # aggregate roots! But this lets us test the events without
        # needing an event bus
        attr_reader :foo

        def initialize(attributes)
          if explosion = attributes[:trigger]
            construction_error("Problem making the object: #{explosion}")
          end

          fire(
            :test_aggregate_created,
            uuid: attributes[:uuid],
            foo: attributes[:foo]
          )
        end

        def operation_that_fails
          invalid_operation("You can't do that")
        end

        def update_foo_without_providing_uuid
          fire(:foo_updated, foo: "unimportant")
        end

        def fire_event_with_no_attributes
          fire(:simple_event)
        end

        private

        def event_factory
          Events
        end

        def apply_test_aggregate_created(event)
          @uuid = event.uuid
          @foo  = event.foo
        end

        def apply_foo_updated(event)
          @foo = event.foo
        end

        def apply_simple_event(event)
          # Nothing to see here
        end
      end

      describe "#create" do
        subject(:aggregate_root) {
          TestAggregateRoot.create(uuid: :aggregate_uuid, foo: "bar")
        }

        it "can be constructed" do
          expect { aggregate_root }.to_not raise_error
        end

        describe "attribute readers for event storage" do
          its(:uuid)               { should be == :aggregate_uuid }
          its(:uncommitted_events) { should be_an Array }
        end

        it "has applied the creation event" do
          expect(aggregate_root.foo).to be == "bar"
        end

        it "has an uncommitted creation event" do
          expect(aggregate_root).to have_uncommitted_events(
            { event_type: :test_aggregate_created, uuid: :aggregate_uuid, foo: "bar" }
          )
        end
      end

      describe "#load_from_history" do
        subject(:aggregate_root) {
          TestAggregateRoot.load_from_history(
            [
              TestAggregateRoot::Events.build(:test_aggregate_created,  foo: "bar",   uuid: :aggregate_uuid),
              TestAggregateRoot::Events.build(:foo_updated,             foo: "quux",  uuid: :aggregate_uuid)
            ]
          )
        }

        it "applies all events in order" do
          expect(aggregate_root.foo).to be == "quux"
        end

        it "has no uncommitted events" do
          expect(aggregate_root.uncommitted_events).to be_empty
        end
      end

      describe "#fire" do
        subject(:aggregate_root) {
          TestAggregateRoot.load_from_history(
            [ TestAggregateRoot::Events.build(:test_aggregate_created, uuid: :aggregate_uuid, foo: "bar") ]
          )
        }

        it "fills in UUIDs when they aren't provided" do
          aggregate_root.update_foo_without_providing_uuid

          expect(aggregate_root).to have_uncommitted_events(
            { event_type: :foo_updated, uuid: :aggregate_uuid, foo: "unimportant" }
          )
        end

        it "can fire events with no attributes" do
          aggregate_root.fire_event_with_no_attributes

          expect(aggregate_root).to have_uncommitted_events(
            { event_type: :simple_event, uuid: :aggregate_uuid }
          )
        end
      end

      describe "#invalid_operation" do
        subject(:aggregate_root) {
          TestAggregateRoot.create(uuid: :aggregate_uuid, foo: "bar")
        }

        it "raises an error" do
          expect {
            aggregate_root.operation_that_fails
          }.to raise_error(InvalidOperationError) { |error|
            expect(error.message).to include("You can't do that")
          }
        end
      end

      describe "#construction_error" do
        it "can raise ConstructionErrors" do
          expect {
            TestAggregateRoot.create(uuid: :aggregate_uuid, foo: "bar", trigger: "boom")
          }.to raise_error(ConstructionError) { |error|
            expect(error.message).to include("Problem making the object", "boom")
          }
        end
      end
    end
  end
end