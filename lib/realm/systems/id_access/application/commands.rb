module Realm
  module Systems
    module IdAccess
      module Application
        Commands = Messaging::MessageFactory.new do |commands|
          commands.define(:sign_up_user,
            properties: { username: String, email_address: String, password: String }
          )
        end
      end
    end
  end
end
