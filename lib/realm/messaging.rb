module Realm
  module Messaging; end
end

# Specifically not loaded:
# require_relative 'messaging/bus'

require_relative 'messaging/message'
require_relative 'messaging/message_factory'
require_relative 'messaging/message_property_error'
require_relative 'messaging/message_type'