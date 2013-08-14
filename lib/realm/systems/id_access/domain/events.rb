module Realm
  module Systems
    module IdAccess
      module Domain
        Events = Messaging::MessageFactory.new do |events|
          events.define(:user_created,
            properties: { uuid: String, username: String, email_address: String }
          )
          events.define(:password_changed,
            properties: { uuid: String, encrypted_password: String }
          )
        end
      end
    end
  end
end
