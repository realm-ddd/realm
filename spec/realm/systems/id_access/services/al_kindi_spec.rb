require 'spec_helper'

require 'realm/systems/id_access/services/al_kindi'

module Realm
  module Systems
    module IdAccess
      module Services
        describe AlKindi do
          subject(:cryptographer) { AlKindi.new }

          it "is not vulnerable to timing attacks" do
            pending "http://www.ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL/PKCS5.html#method-c-pbkdf2_hmac"
          end

          describe "#encrypt_password" do
            subject(:encrypted_password) {
              cryptographer.encrypt_password("correct horse battery staple")
            }

            specify "Base64 encoded" do
              # Take my word for it
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
                  "correct horse battery staple", salt: "16bytesascii8bit"
                )
              }.to_not be == encrypted_password[:encrypted_password]
            end

            describe "encryption parameters" do
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
