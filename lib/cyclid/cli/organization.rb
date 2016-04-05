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

      # Commands for managing organization members
      class Member < Thor
        desc 'add USERS', 'Add users to the organization'
        def add(*users)
          client = Cyclid::Client::Tilapia.new(options[:config], debug?)

          begin
            org = client.org_get(client.config.organization)

            # Concat the new list with the existing list and remove any
            # duplicates.
            user_list = org['users']
            user_list.concat users
            user_list.uniq!

            client.org_modify(client.config.organization,
                              members: user_list)
          rescue StandardError => ex
            abort "Failed to add users to the organization: #{ex}"
          end
        end

        desc 'permission USER PERMISSION', 'Modify a members organization permissions'
        long_desc <<-LONGDESC
          Modify the organization permissions for USER.

          PERMISSION must be one of:
            * admin - Give the user organization administrator permissions.
            * write - Give the user organization create/modify permissions.
            * read  - Give the user organization read permissions.
            * none  - Remove all organization permissions.

          With 'none' the user remains an organization member but can not
          interact with it. See the 'member remove' command if you want to
          actually remove a user from your organization.
        LONGDESC
        def permission(user, permission)
          client = Cyclid::Client::Tilapia.new(options[:config], debug?)

          begin
            perms = case permission.downcase
                    when 'admin'
                      { 'admin' => true, 'write' => true, 'read' => true }
                    when 'write'
                      { 'admin' => false, 'write' => true, 'read' => true }
                    when 'read'
                      { 'admin' => false, 'write' => false, 'read' => true }
                    when 'none'
                      { 'admin' => false, 'write' => false, 'read' => false }
                    else
                      raise "invalid permission #{permission}"
                    end

            client.org_user_permissions(client.config.organization, user, perms)
          rescue StandardError => ex
            abort "Failed to modify user permissions: #{ex}"
          end
        end
        map 'perms' => :permission

        desc 'list', 'List organization members'
        def list
          client = Cyclid::Client::Tilapia.new(options[:config], debug?)

          begin
            org = client.org_get(client.config.organization)
            org['users'].each do |user|
              puts user
            end
          rescue StandardError => ex
            abort "Failed to get organization members: #{ex}"
          end
        end

        desc 'show USER', 'Show details of an organization member'
        def show(user)
          client = Cyclid::Client::Tilapia.new(options[:config], debug?)

          begin
            user = client.org_user_get(client.config.organization, user)

            # Pretty print the user details
            puts 'Username: '.colorize(:cyan) + user['username']
            puts 'Email: '.colorize(:cyan) + user['email']
            puts 'Permissions'.colorize(:cyan)
            user['permissions'].each do |k, v|
              puts "\t#{k.capitalize}: ".colorize(:cyan) + v.to_s
            end
          rescue StandardError => ex
            abort "Failed to get user: #{ex}"
          end
        end

        desc 'remove USERS', 'Remove users from the organization'
        long_desc <<-LONGDESC
          Remove the list of USERS from the organization.

          The --force option will remove the users without asking for confirmation.
        LONGDESC
        option :force, aliases: '-f', type: :boolean
        def remove(*users)
          client = Cyclid::Client::Tilapia.new(options[:config], debug?)

          begin
            org = client.org_get(client.config.organization)

            # Remove any users that exist as members of this organization;
            # ask for confirmation on a per-user basis (unless '-f' was passed)
            user_list = org['users']
            user_list.delete_if do |user|
              if users.include? user
                if options[:force]
                  true
                else
                  print "Remove user #{user}: are you sure? (Y/n): ".colorize(:red)
                  STDIN.getc.chr.casecmp('y') == 0
                end
              end
            end
            user_list.uniq!

            client.org_modify(client.config.organization,
                              members: user_list)
          rescue StandardError => ex
            abort "Failed to remove users from the organization: #{ex}"
          end
        end
      end
      desc 'member', 'Manage organization members'
      subcommand 'member', Member

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
      def use(name = nil)
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
          abort 'No such organization' unless File.exist?(fname)
          abort 'Not a valid organization' unless File.file?(fname)

          begin
            config = Cyclid::Client::Config.new(fname)

            raise if config.server.nil? or \
                     config.organization.nil? or \
                     config.username.nil? or \
                     config.secret.nil?
          rescue StandardError
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
