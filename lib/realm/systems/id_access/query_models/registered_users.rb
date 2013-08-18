require 'celluloid'

module Realm
  module Systems
    module IdAccess
      module QueryModels
        class RegisteredUsers
          include Celluloid

          def initialize(database)
            @database = database
          end

          def handle_user_created(event)
            @database.save(
              uuid:           event.uuid,
              username:       event.username,
              email_address:  event.email_address
            )
          end

          def count
            @database.count
          end

          def records
            @database.records
          end

          def record_for(query)
            records.detect { |record|
              query.all? { |field, value| record[field] == value }
            }
          end

          def records_for(query)
            records.select { |record|
              query.all? { |field, value| record[field] == value }
            }
          end
        end
      end
    end
  end
end
