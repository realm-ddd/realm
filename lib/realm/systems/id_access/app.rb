require 'facets/hash/deep_merge'
require 'realm/domain/validation'

module Realm
  module Systems
    module IdAccess
      class App
        def initialize(
            message_bus:    required(:message_bus),
            event_store:    required(:event_store),
            query_database: required(:query_database),
            cryptographer:  required(:cryptographer),
            config:         { })
          @message_bus    = message_bus
          @event_store    = event_store
          @query_database = query_database
          @cryptographer  = cryptographer
          @config         = default_config.deep_merge(config)
        end

        def boot
          # Query models first because command handlers may depend on them
          connect_query_models
          connect_command_handlers
        end

        private

        def connect_command_handlers
          @message_bus.register(:sign_up_user,
            Application::CommandHandlers::SignUpUser.new(
              user_registry: user_registry,
              user_service:  user_service,
              cryptographer: @cryptographer,
              validator:     @config[:commands][:sign_up_user][:validator]
            )
          )
        end

        def connect_query_models
          connect_query_model(:registered_users,
            query_model_class: QueryModels::RegisteredUsers,
            events:           [ :user_created ]
          )
        end

        # Hijacked from Harvest, maybe we could put this on the message bus?
        # (In normal production use, we want each read model listening to all
        # the events it understands.)
        def connect_query_model(name, options)
          query_models[name] =
            options[:query_model_class].new(@query_database[name])

          options[:events].each do |event_name|
            @message_bus.register(event_name, query_models[name])
          end
        end

        def query_models
          @query_models ||= Hash.new
        end

        def user_registry
          @user_registry ||= Domain::UserRegistry.new(@event_store)
        end

        def user_service
          @user_service ||= Domain::UserService.new(registered_users: query_models[:registered_users])
        end

        def default_config
          {
            commands: {
              sign_up_user: {
                validator: Realm::Domain::Validation::CommandValidator.new
              }
            }
          }
        end
      end
    end
  end
end
