require 'facets/hash/deep_merge'
require 'realm/domain/validation'

module Realm
  module Systems
    module IdAccess
      class App
        def initialize(
            message_bus:    required(:message_bus),
            event_store:    required(:event_store),
            cryptographer:  required(:cryptographer),
            config:         { })
          @message_bus    = message_bus
          @event_store    = event_store
          @cryptographer  = cryptographer
          @config         = default_config.deep_merge(config)
        end

        def boot
          connect_command_handlers
        end

        private

        def connect_command_handlers
          @message_bus.register(:sign_up_user,
            Application::CommandHandlers::SignUpUser.new(
              user_registry: user_registry,
              cryptographer: @cryptographer,
              validator:     @config[:commands][:sign_up_user][:validator]
            )
          )
        end

        def user_registry
          @user_registry ||= Domain::UserRegistry.new(@event_store)
        end

        def default_config
          {
            commands: {
              sign_up_user: {
                validator: Realm::Domain::Validation::EntityValidator.new
              }
            }
          }
        end
      end
    end
  end
end
