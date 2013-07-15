require 'spec_helper'

require 'realm/domain'
require 'realm/spec'

describe "expect(event).to match_event_description(...)" do
  let(:event_type) {
    Realm::Domain::EventFactory::EventType.new(:test_event_type, [ :foo ])
  }
  subject(:event) { event_type.new_event(event_type: :test_event_type, uuid: :test_uuid, foo: "bar") }

  it "matches when it matches" do
    expect(event).to match_event_description(event_type: :test_event_type, uuid: :test_uuid, foo: "bar")
  end

  it "doesn't match when it doesn't match" do
    expect(event).to_not match_event_description(event_type: :test_event_type, uuid: :test_uuid, foo: "baz")
  end
end