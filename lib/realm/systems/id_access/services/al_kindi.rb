require 'openssl'
require 'base64'

module Realm
  module Systems
    module IdAccess
      module Services
        class AlKindi
          def encrypt_password(password, salt: random_salt)
            digest      = OpenSSL::Digest::SHA256.new
            length      = digest.length
            iterations  = 32768

            encrypted_password = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iterations, length, digest)

            {
              encrypted_password: Base64.encode64(encrypted_password),
              salt:               salt,
              algorithm:          "PBKDF2-HMAC",
              iterations:         32768,
              digest:             digest.class.name.split("::").last,
              length:             length
            }
          end

          private

          def random_salt
            Base64.encode64(
              OpenSSL::Random.random_bytes(16)
            )
          end
        end
      end
    end
  end
end
