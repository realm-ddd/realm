require 'spec_helper'

require 'realm/systems/id_access/domain/events'
require 'realm/systems/id_access/query_models/registered_users'

module Realm
  module Systems
    module IdAccess
      module QueryModels
        # This is taken from one of the Harvest query models. I considered writing
        # a Sequel implementation of it but in the end I decided to defer that until
        # we solve persistence properly.
        # This interface to the "database" is no good, though, it can't be replaced
        # with anything more sophisticated while we're using #select, #detect etc.
        describe RegisteredUsers do
          let(:database) {
            double(
              "QueryDatabase",
              save: nil,
              delete: nil,
              records: [
                { uuid: :uuid_1, data: "data 1a" },
                { uuid: :uuid_1, data: "data 1b" },
                { uuid: :uuid_2, data: "data 2a" }
              ],
              count: 3
            )
          }

          # We need this dependency for the bus even though it's only used
          # for #send - either we need to change the design or provide a way
          # to construct this without an explicit unused dependency here
          let(:result_factory) { :_unused_ }

          let(:event_bus) { Messaging::Bus::SimpleMessageBus.new(result_factory: result_factory) }
          subject(:view) { RegisteredUsers.new(database) }

          before(:each) do
            event_bus.register(:unhandled_event, Messaging::Bus::UnhandledMessageSentinel.new)
          end

          describe "#handle_user_created" do
            before(:each) do
              event_bus.register(:user_created, view)
            end

            it "saves the view info" do
              database.should_receive(:save).with(
                uuid:           :user_uuid,
                username:       "new_username",
                email_address:  "example@email.com"
              )

              event_bus.publish(
                Domain::Events.build(:user_created,
                  uuid:           :user_uuid,
                  username:       "new_username",
                  email_address:  "example@email.com"
                )
              )
            end
          end

          describe "#count" do
            it "is the number of records in the database" do
              expect(view.count).to be == 3
            end
          end

          describe "#records" do
            it "is the database records" do
              expect(view.records).to be == [
                { uuid: :uuid_1, data: "data 1a" },
                { uuid: :uuid_1, data: "data 1b" },
                { uuid: :uuid_2, data: "data 2a" }
              ]
            end
          end

          describe "querying" do
            before(:each) do
              database.stub(
                records: [
                  { uuid: :uuid_1, data: "data a", extra: "extra data" },
                  { uuid: :uuid_1, data: "data b", extra: "extra data" },
                  { uuid: :uuid_2, data: "data b", extra: "extra data" }
                ]
              )
            end

            describe "#record_for" do
              it "returns the record for the query" do
                expect(
                  view.record_for(uuid: :uuid_1, data: "data b")
                ).to be == { uuid: :uuid_1, data: "data b", extra: "extra data" }
              end

              it "returns only the first record" do
                expect(
                  view.record_for(data: "data b")
                ).to be == { uuid: :uuid_1, data: "data b", extra: "extra data" }
              end
            end

            describe "#records_for" do
              it "returns all the records for the query" do
                expect(
                  view.records_for(uuid: :uuid_1)
                ).to be == [
                  { uuid: :uuid_1, data: "data a", extra: "extra data" },
                  { uuid: :uuid_1, data: "data b", extra: "extra data" }
                ]
              end
            end
          end
        end
      end
    end
  end
end
