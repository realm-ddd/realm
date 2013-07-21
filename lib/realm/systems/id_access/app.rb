module Realm
  module Systems
    module IdAccess
      class App
        def initialize(message_bus: r(:message_bus), event_store: r(:event_store), cryptographer: r(:cryptographer))
          @message_bus    = message_bus
          @event_store    = event_store
          @cryptographer  = cryptographer
        end

        def boot
          connect_command_handlers
        end

        private

        def connect_command_handlers
          @message_bus.register(:sign_up_user,
            Application::CommandHandlers::SignUpUser.new(
              user_registry: user_registry,
              cryptographer: @cryptographer
            )
          )
        end

        def user_registry
          @user_registry ||= Domain::UserRegistry.new(@event_store)
        end
      end
    end
  end
end
