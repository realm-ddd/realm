require 'spec_helper'

require 'realm/uuid'

describe Realm do
  describe ".uuid" do
    subject { Realm.uuid }

    its(:class) { should be UUIDTools::UUID }
    its(:version) { should be 4 }
  end
end
