# Copyright 2016 Liqwyd Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'colorize'

module Cyclid
  module Cli
    # 'secret' sub-command
    class Secret < Thor
      desc 'encrypt', 'Encrypt a secret with the organizations public key'
      def encrypt
        # Get the organizations public key in a form we can use
        org = client.org_get(client.config.organization)
        der_key = Base64.decode64(org['public_key'])
        public_key = OpenSSL::PKey::RSA.new(der_key)

        # Get the secret in a safe manner
        print 'Secret: '
        secret = STDIN.noecho(&:gets).chomp
        print "\r"

        # Encrypt with the public key
        encrypted = public_key.public_encrypt(secret)

        puts 'Secret: '.colorize(:cyan) + Base64.strict_encode64(encrypted)
      rescue StandardError => ex
        abort "Failed to encrypt secret: #{ex}"
      end
    end
  end
end
