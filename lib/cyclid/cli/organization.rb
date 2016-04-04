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

      desc 'list', 'List your available organizations'
      def list
        Dir.glob("#{CYCLID_CONFIG_DIR}/*").each do |fname|
          next if File.symlink?(fname)
          next unless File.file?(fname)

          begin
            # Create a Config from this file and display the details
            config = Cyclid::Client::Config.new(fname)

            puts File.basename(fname).colorize(:cyan)
            uri = URI::HTTP.build(host: config.server, port: config.port)
            puts "\tServer: ".colorize(:cyan) + uri.to_s
            puts "\tOrganization: ".colorize(:cyan) + config.organization
            puts "\tUsername: ".colorize(:cyan) + config.username
          rescue StandardError => ex
            STDERR.puts "Failed to load config file #{fname}: #{ex}"
          end
        end
      end

      desc 'use NAME', 'Select the organization NAME to use by default'
      def use(name=nil)
        # If 'use' was called without an argument, print the name of the
        # current configuration
        if name.nil?
          fname = if File.symlink?(options[:config])
                    File.readlink(options[:config])
                  else
                    options[:config]
                  end
          puts File.basename(fname)
        else
          # List the avialble configurations
          fname = File.join(CYCLID_CONFIG_DIR, name)

          # Sanity check that the configuration file exists and is valid
          abort 'No such organization' unless File.exists?(fname)
          abort 'Not a valid organization' unless File.file?(fname)

          begin
            config = Cyclid::Client::Config.new(fname)

            raise if config.server.nil? or \
                     config.organization.nil? or \
                     config.username.nil? or \
                     config.secret.nil?
          rescue StandardError => ex
            abort 'Invalid configuration file'
          end

          # The configuration file exists and appears to be sane, so switch the
          # 'config' symlink to point to it.
          Dir.chdir(CYCLID_CONFIG_DIR) do
            File.delete('config')
            File.symlink(name, 'config')
          end
        end
      end
    end
  end
end
