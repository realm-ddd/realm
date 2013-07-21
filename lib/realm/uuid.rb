require 'uuidtools'

module Realm
  def self.uuid
    UUIDTools::UUID.random_create
  end
end