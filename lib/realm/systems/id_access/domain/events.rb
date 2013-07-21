module Realm
  module Systems
    module IdAccess
      module Domain
        Events = Messaging::MessageFactory.new do |events|
          events.define(:user_created,      :uuid, :username, :email_address)
          events.define(:password_changed,  :uuid, :encrypted_password)
        end
      end
    end
  end
end
