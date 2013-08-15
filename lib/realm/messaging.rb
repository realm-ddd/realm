module Realm
  module Messaging
    # Celluloid treats ArgumentErrors specially, so until I decide it's safe
    # to create subclasses of them, we'll use MessagingError for now
    class MessagingError < RuntimeError; end
  end
end

require_relative 'messaging/bus'
require_relative 'messaging/errors'
require_relative 'messaging/formatting'
require_relative 'messaging/handlers'
require_relative 'messaging/message'
require_relative 'messaging/message_factory'
require_relative 'messaging/message_type'
require_relative 'messaging/result'
require_relative 'messaging/result_factory'
