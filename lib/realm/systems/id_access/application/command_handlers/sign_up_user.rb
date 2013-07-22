module Realm
  module Systems
    module IdAccess
      module Application
        module CommandHandlers
          class SignUpUser
            def initialize(user_registry: r(:user_registry), cryptographer: r(:cryptographer), validator: r(:validator))
              @user_registry        = user_registry
              @cryptographer        = cryptographer
              @validator_prototype  = validator
            end

            def handle_sign_up_user(command, response_port: required(:response_port))
              user = create_user(command)
              validator = @validator_prototype.dup
              validator.validate(user)

              if validator.entity_valid?
                user.change_password(command.password, cryptographer: @cryptographer)
                @user_registry.register(user)
                response_port.user_created(uuid: user.uuid)
              else
                response_port.user_invalid(message: validator.message)
              end
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
