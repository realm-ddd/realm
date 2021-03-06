require 'spec_helper'

require 'realm/event_store'
require 'realm/domain'

module TestModule; end

module Realm
  module Domain
    describe EventStoreRepository do
      let(:event_store) {
        double(EventStore, save_events: nil, history_for_aggregate: [ :old_event_1, :old_event_2 ])
      }

      let(:aggregate_root_class) { Class.new }
      let(:aggregate_root) {
        double(aggregate_root_class, uuid: :aggregate_uuid, uncommitted_events: [ :event_1, :event_2 ])
      }

      before(:each) do
        TestModule.const_set(:TestAggregateRoot, aggregate_root_class)
      end

      after(:each) do
        TestModule.send(:remove_const, :TestAggregateRoot)
      end

      # This is the source of things
      let(:repository_class) {
        Domain.event_store_repository("TestModule::TestAggregateRoot")
      }
      subject(:repository) { repository_class.new(event_store) }

      before(:each) do
        aggregate_root_class.stub(load_from_history: aggregate_root)
      end

      describe ".domain_term_for" do
        # This is the source of things
        let(:repository_class) {
          Domain.event_store_repository("TestModule::TestAggregateRoot") do
            domain_term_for :save, :become_aware_of
          end
        }

        it "aliases the method" do
          repository.become_aware_of(aggregate_root)
          expect(event_store).to have_received(:save_events).with(:aggregate_uuid, [ :event_1, :event_2 ])
        end

        it "makes the old method private" do
          expect {
            repository.save(aggregate_root)
          }.to raise_error(NoMethodError) { |error|
            expect(error.message).to include("private method")
          }
        end
      end

      describe "#save" do
        it "saves the events" do
          repository.save(aggregate_root)
          expect(event_store).to have_received(:save_events).with(:aggregate_uuid, [ :event_1, :event_2 ])
        end
      end

      describe "#update" do
        it "saves the events" do
          repository.update(aggregate_root)
          expect(event_store).to have_received(:save_events).with(:aggregate_uuid, [ :event_1, :event_2 ])
        end
      end

      describe "#get_by_id" do
        it "loads the history" do
          repository.get_by_id(:aggregate_uuid)
          expect(event_store).to have_received(:history_for_aggregate).with(:aggregate_uuid)
        end

        it "creates an AggregateRoot from the history" do
          repository.get_by_id(:aggregate_uuid)
          expect(aggregate_root_class).to have_received(:load_from_history).with([ :old_event_1, :old_event_2 ])
        end

        it "returns the AggregateRoot" do
          expect(repository.get_by_id(:aggregate_uuid)).to be_equal(aggregate_root)
        end
      end
    end
  end
end