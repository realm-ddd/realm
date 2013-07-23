require 'spec_helper'

require 'realm/spec/validators'

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

            let(:user_service) {
              double("UserService",
                username_available?:      username_available?,
                email_address_available?: email_address_available?
              )
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
              SignUpUser.new(
                user_registry: user_registry,
                user_service:  user_service,
                cryptographer: cryptographer,
                validator:     validator
              )
            }

            describe "#sign_up_user" do
              def sign_up_user
                handler.handle_sign_up_user(command, response_port: response_port)
              end

              before(:each) do
                sign_up_user
              end

              context "success" do
                let(:username_available?)       { true }
                let(:email_address_available?)  { true }

                let(:validator) { Realm::Domain::Validation::AlwaysValidValidator.new }

                it "makes a User" do
                  expect(Domain::User).to have_received(:create).with(
                    username: "new_username", email_address: "email@example.com"
                  )
                end

                it "validates the User" do
                  expect(validator).to have_been_used_to_validate(command)
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

              context "invalid" do
                let(:username_available?)       { true }
                let(:email_address_available?)  { true }

                let(:validator) { Realm::Domain::Validation::AlwaysInvalidValidator.new(message: "validation message") }

                it "doesn't make a User" do
                  expect(Domain::User).to_not have_received(:create)
                end

                it "validates the User" do
                  expect(validator).to have_been_used_to_validate(command)
                end

                it "notifies the listener" do
                  expect(response_port).to have_received(:user_invalid).with(message: "validation message")
                end
              end

              context "conflict" do
                # The command is valid, but the username / email are taken
                let(:validator) { Realm::Domain::Validation::AlwaysValidValidator.new }

                context "username taken" do
                  let(:username_available?)       { false }
                  let(:email_address_available?)  { true }

                  it "checks the username" do
                    expect(user_service).to have_received(:username_available?).with("new_username")
                  end

                  it "doesn't register the User" do
                    expect(user_registry).to_not have_received(:register)
                  end

                  it "notifies the listener" do
                    expect(response_port).to have_received(:user_conflicts).with(message: "Username taken")
                  end
                end

                context "email address taken" do
                  let(:username_available?)       { true }
                  let(:email_address_available?)  { false }

                  it "checks the email address" do
                    expect(user_service).to have_received(:email_address_available?).with("email@example.com")
                  end

                  it "doesn't register the User" do
                    expect(user_registry).to_not have_received(:register)
                  end

                  it "notifies the listener" do
                    expect(response_port).to have_received(:user_conflicts).with(message: "Email address taken")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
