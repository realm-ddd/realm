module Realm
  module Systems
    module IdAccess
      module Application
        module CommandHandlers
          class SignUpUser
            def initialize(user_registry: required(:user_registry),
                           user_service:  required(:user_service),
                           cryptographer: required(:cryptographer),
                           validator:     required(:validator))
              @user_registry  = user_registry
              @user_service   = user_service
              @cryptographer  = cryptographer
              @validator      = validator
            end

            def handle_sign_up_user(command, response_port: required(:response_port))
              validation_result = @validator.validate(command)

              if validation_result.valid?
                user = create_user(command)
                user.change_password(command.password, cryptographer: @cryptographer)
                if !@user_service.username_available?(command.username)
                  response_port.user_conflicts(message: "Username taken")
                elsif !@user_service.email_address_available?(command.email_address)
                  response_port.user_conflicts(message: "Email address taken")
                else
                  @user_registry.register(user)
                  response_port.user_created(uuid: user.uuid)
                end
              else
                response_port.user_invalid(message: validation_result.message)
              end
            end

            private

            def create_user(command)
              Domain::User.create(username: command.username, email_address: command.email_address)
            end
          end
        end
      end
    end
  end
end
