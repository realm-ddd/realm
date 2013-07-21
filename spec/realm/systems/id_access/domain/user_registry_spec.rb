require 'spec_helper'

require 'realm/event_store'
require 'realm/systems/id_access/domain'

module Realm
  module Systems
    module IdAccess
      module Domain
        describe UserRegistry do
          let(:event_store) {
            double(EventStore, save_events: nil, history_for_aggregate: [ :old_event_1, :old_event_2 ])
          }
          subject(:user_registry) { UserRegistry.new(event_store) }

          it "is an EventStoreRepository" do
            # We've reduced the implementation of these to little more than naming...
            expect(user_registry.class).to be_a(Realm::Domain::EventStoreRepository)
          end
        end
      end
    end
  end
end
