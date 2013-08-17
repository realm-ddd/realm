module Realm
  module Systems
    module IdAccess
      module Application
        Commands = Messaging::MessageFactory.new(system_name: :id_access) do |commands|
          commands.define(:sign_up_user,
            properties: { username: String, email_address: String, password: String },
            responses: [ :user_created, :user_conflicts, :user_invalid ]
          )
        end

        Responses = Messaging::MessageFactory.new(system_name: :id_access) do |responses|
          responses.define(:user_created,   properties: { uuid: UUIDTools::UUID })
          responses.define(:user_conflicts, properties: { message: String })
          responses.define(:user_invalid,   properties: { message: String })
        end
      end
    end
  end
end
