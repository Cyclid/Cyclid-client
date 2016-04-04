require 'colorize'

module Cyclid
  module Cli
    # 'organization' sub-command
    class Organization < Thor
      desc 'show', 'Show details of the organization'
      def show
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          org = client.org_get(client.config.organization)

          # Convert the public key to PEM
          der_key = Base64.decode64(org['public_key'])
          public_key = OpenSSL::PKey::RSA.new(der_key)

          # Pretty print the organization details
          puts 'Name: '.colorize(:cyan) + org['name']
          puts 'Owner Email: '.colorize(:cyan) + org['owner_email']
          puts 'Public Key: '.colorize(:cyan) + public_key.to_pem
          puts 'Members:'.colorize(:cyan)
          if org['users'].any?
            org['users'].each do |user|
              puts "\t#{user}"
            end
          else
            puts "\tNone"
          end
        rescue StandardError => ex
          abort "Failed to get organization: #{ex}"
        end
      end

      desc 'modify', 'Modify the organization'
      long_desc <<-LONGDESC
        Modify the organization.

        The --email option sets the owners email address.
      LONGDESC
      option :email, aliases: '-e'
      def modify
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          client.org_modify(client.config.organization,
                            owner_email: options[:email])
        rescue StandardError => ex
          abort "Failed to modify organization: #{ex}"
        end
      end
    end
  end
end
