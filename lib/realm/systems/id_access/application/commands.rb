module Realm
  module Systems
    module IdAccess
      module Application
        Commands = Messaging::MessageFactory.new do |commands|
          commands.define(:sign_up_user, :username, :email_address, :password)
        end
      end
    end
  end
end
