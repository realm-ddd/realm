module Realm
  module Systems
    module IdAccess
      module Domain
        class User
          extend Realm::Domain::AggregateRoot

          def initialize(attributes)
            fire(:user_created,
              uuid:           Realm.uuid,
              username:       attributes.fetch(:username),
              email_address:  attributes.fetch(:email_address)
            )
          end

          def change_password(new_password, cryptographer: required(:cryptographer))
            fire(:password_changed,
              encrypted_password: cryptographer.encrypt_password(new_password)
            )
          end

          def declare_username(listener)
            listener.attribute_declared(:username, @username)
          end

          def declare_email_address(listener)
            listener.attribute_declared(:email_address, @email_address)
          end

          private

          def apply_user_created(event)
            @uuid           = event.uuid
            @username       = event.username
            @email_address  = event.email_address
          end

          def apply_password_changed(event)
            # Commented out until we actually need them...
            # @encrypted_password = event.encrypted_password
          end

          def event_factory
            Events
          end
        end
      end
    end
  end
end
