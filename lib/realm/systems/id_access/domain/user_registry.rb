module Realm
  module Systems
    module IdAccess
      module Domain
        UserRegistry = Realm::Domain.event_store_repository("Realm::Systems::IdAccess::Domain::User") do
          domain_term_for :save, :register
        end
      end
    end
  end
end
