require 'spec_helper'

require 'realm/systems/id_access/application/commands'
require 'realm/systems/id_access/application/command_handlers/sign_up_user'
require 'realm/systems/id_access/domain/user'
require 'realm/systems/id_access/domain/user_registry'

module Realm
  module Systems
    module IdAccess
      module Application
        module CommandHandlers
          describe SignUpUser do
            let(:user_registry) {
              double(Domain::UserRegistry, register: nil)
            }

            let(:user) {
              double(Domain::User, uuid: :user_uuid, change_password: nil)
            }

            before(:each) do
              Domain::User.stub(create: user)
            end

            let(:command) {
              Commands.build(
                :sign_up_user,
                username:       "new_username",
                email_address:  "email@example.com",
                password:       "initial password"
              )
            }

            let(:response_port) {
              double("Response Port", user_created: nil, user_invalid: nil, user_conflicts: nil)
            }

            let(:cryptographer) {
              double("Cryptographer", hash_password: :opaque_hashed_password)
            }

            subject(:handler) {
              SignUpUser.new(user_registry: user_registry, cryptographer: cryptographer)
            }

            describe "#sign_up_user" do
              def sign_up_user
                handler.handle_sign_up_user(command, response_port: response_port)
              end

              before(:each) do
                sign_up_user
              end

              context "success" do
                it "makes a User" do
                  expect(Domain::User).to have_received(:create).with(
                    username: "new_username", email_address: "email@example.com"
                  )
                end

                it "sets the password" do
                  expect(user).to have_received(:change_password).with("initial password", cryptographer: cryptographer)
                end

                it "saves the User" do
                  expect(user_registry).to have_received(:register).with(user)
                end

                it "notifies the listener of the User's UUID" do
                  expect(response_port).to have_received(:user_created).with(uuid: :user_uuid)
                end
              end

              context "conflict" do
                it "does something" do
                  pending
                end
              end

              context "invalid" do
                it "does something" do
                  pending
                end
              end
            end
          end
        end
      end
    end
  end
end
