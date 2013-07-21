module Realm
  module Systems
    module IdAccess
      module Application
        module CommandHandlers
          class SignUpUser
            def initialize(user_registry: required(:user_registry), cryptographer: required(:cryptographer))
              @user_registry = user_registry
              @cryptographer = cryptographer
            end

            def handle_sign_up_user(command, response_port: required(:response_port))
              user = create_user(command)
              user.change_password(command.password, cryptographer: @cryptographer)
              @user_registry.register(user)
              response_port.user_created(uuid: user.uuid)
            end

            private

            def create_user(command)
              Domain::User.create(
                username: command.username, email_address: command.email_address
              )
            end
          end
        end
      end
    end
  end
end
