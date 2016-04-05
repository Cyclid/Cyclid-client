require 'colorize'

module Cyclid
  module Cli
    # 'secret' sub-command
    class Secret < Thor
      desc 'sign', 'Sign a secret with the organizations public key'
      def sign
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

        puts "Secret: ".colorize(:cyan) + Base64.strict_encode64(encrypted)
      rescue
        abort "Failed to sign secret: #{ex}"
      end
    end
  end
end
