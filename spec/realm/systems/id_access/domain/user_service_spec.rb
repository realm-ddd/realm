require 'spec_helper'

require 'realm/systems/id_access/domain/user_service'

module Realm
  module Systems
    module IdAccess
      module Domain
        describe UserService do
          let(:registered_users) {
            double("Registered Users Query Model", record_for: user_record_found)
          }

          subject(:service) { UserService.new(registered_users: registered_users) }

          describe "#username_available?" do
            context "username available" do
              let(:user_record_found) { nil }

              it "queries the read model" do
                service.username_available?("desired_username")
                expect(registered_users).to have_received(:record_for).with(username: "desired_username")
              end

              it "is true" do
                expect(service.username_available?("username")).to be_true
              end
            end

            context "username taken" do
              let(:user_record_found) { :a_record }

              it "queries the read model" do
                service.username_available?("desired_username")
                expect(registered_users).to have_received(:record_for).with(username: "desired_username")
              end

              it "is false" do
                expect(service.username_available?("username")).to be_false
              end
            end
          end

          describe "#email_address_available?" do
            context "email_address available" do
              let(:user_record_found) { nil }

              it "queries the read model" do
                service.email_address_available?("desired@email.com")
                expect(registered_users).to have_received(:record_for).with(email_address: "desired@email.com")
              end

              it "is true" do
                expect(service.email_address_available?("email_address")).to be_true
              end
            end

            context "email_address taken" do
              let(:user_record_found) { :a_record }

              it "queries the read model" do
                service.email_address_available?("desired@email.com")
                expect(registered_users).to have_received(:record_for).with(email_address: "desired@email.com")
              end

              it "is false" do
                expect(service.email_address_available?("email_address")).to be_false
              end
            end
          end
        end
      end
    end
  end
end
