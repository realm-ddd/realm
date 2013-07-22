require 'spec_helper'
require 'benchmark'

require 'realm/systems/id_access/services/al_kindi'

module Realm
  module Systems
    module IdAccess
      module Services
        describe AlKindi, speed: :slow do
          subject(:cryptographer) { AlKindi.new }

          describe "#encrypt_password" do
            subject(:encrypted_password) {
              cryptographer.encrypt_password("correct horse battery staple")
            }

            specify "Base64 encoded" do
              # Take my word for it
            end

            it "is slow" do
              expect(
                Benchmark.realtime do
                  cryptographer.encrypt_password("correct horse battery staple")
                end
              ).to be > 0.01 # seconds
            end

            specify "re-encryption with correct salt" do
              expect(
                cryptographer.encrypt_password(
                  "correct horse battery staple", salt: encrypted_password[:salt]
                )[:encrypted_password]
              ).to be == encrypted_password[:encrypted_password]
            end

            specify "re-encryption with incorrect password" do
              expect {
                cryptographer.encrypt_password(
                  "password", salt: encrypted_password[:salt]
                )
              }.to_not be == encrypted_password[:encrypted_password]
            end

            specify "re-encryption with incorrect salt" do
              expect {
                cryptographer.encrypt_password(
                  "correct horse battery staple", salt: "wrong salt not even encoded properly"
                )
              }.to_not be == encrypted_password[:encrypted_password]
            end

            describe "encryption parameters" do
              specify "version (for future backwards compatibility)" do
                expect(encrypted_password[:version]).to be == 1
              end

              specify "algorithm" do
                expect(encrypted_password[:algorithm]).to be == "PBKDF2-HMAC"
              end

              specify "iterations" do
                expect(encrypted_password[:iterations]).to be == 32768
              end

              specify "digest" do
                expect(encrypted_password[:digest]).to be == "SHA256"
              end

              specify "length" do
                expect(encrypted_password[:length]).to be == 32
              end
            end
          end
        end
      end
    end
  end
end
