require_relative 'realm/core_ext'
require_relative 'realm/domain'
require_relative 'realm/event_store'
require_relative 'realm/messaging'
require_relative 'realm/uuid'

# Specifically not auto-required as we don't need this stuff in production:
# require_relative 'realm/spec'