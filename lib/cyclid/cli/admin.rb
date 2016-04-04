require 'base64'
require 'openssl'

module Cyclid
  module Cli
    # 'admin user' sub-commands
    class AdminUser < Thor
      desc 'list', 'List all of the users'
      def list
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          users = client.user_list
          users.each do |user|
            puts user
          end
        rescue StandardError => ex
          abort "Failed to retrieve list of users: #{ex}"
        end
      end

      desc 'show USERNAME', 'Show details of the user USERNAME'
      def show(username)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          user = client.user_get(username)

          # Pretty print the user details
          puts 'Username: '.colorize(:cyan) + user['username']
          puts 'Email: '.colorize(:cyan) + user['email']
          puts 'Organizations:'.colorize(:cyan)
          if user['organizations'].any?
            user['organizations'].each do |org|
              puts "\t#{org}"
            end
          else
            puts "\tNone"
          end
        rescue StandardError => ex
          abort "Failed to get user: #{ex}"
        end
      end

      desc 'create USERNAME EMAIL', 'Create a new user USERNAME'
      long_desc <<-LONGDESC
        Create a user USERNAME with the email address EMAIL. The new user will not be a member of
        any organization.

        The --password option sets an encrypted password for HTTP Basic authentication and Cyclid
        UI console logins.

        The --secret option sets a shared secret which is used for signing Cyclid API requests.

        One of either --password or --secret should be used if you want the user to be able to
        authenticate with the server.
      LONGDESC
      option :password, aliases: '-p'
      option :secret, aliases: '-s'
      def create(username, email)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          client.user_add(username, email, options[:password], options[:secret])
        rescue StandardError => ex
          abort "Failed to create new user: #{ex}"
        end
      end

      desc 'modify USERNAME', 'Modify the user USERNAME'
      long_desc <<-LONGDESC
        Modify the user USERNAME.

        The --email option sets the users email address.

        The --password option sets an encrypted password for HTTP Basic authentication and Cyclid
        UI console logins.

        The --secret option sets a shared secret which is used for signing Cyclid API requests.
      LONGDESC
      option :email, aliases: '-e'
      option :password, aliases: '-p'
      option :secret, aliases: '-s'
      def modify(username)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          client.user_modify(username,
                             email: options[:email],
                             password: options[:password],
                             secret: options[:secret])
        rescue StandardError => ex
          abort "Failed to modify user: #{ex}"
        end
      end

      desc 'passwd USERNAME', 'Change the password of the user USERNAME'
      def passwd(username)
        # Get the new password
        print 'Password: '
        password = STDIN.noecho(&:gets).chomp
        print "\nConfirm password: "
        confirm = STDIN.noecho(&:gets).chomp
        print "\n"
        abort 'Passwords do not match' unless password == confirm

        # Modify the user with the new password
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          client.user_modify(username, password: password)
        rescue StandardError => ex
          abort "Failed to modify user: #{ex}"
        end
      end

      desc 'delete USERNAME', 'Delete the user USERNAME'
      long_desc <<-LONGDESC
        Delete the user USERNAME from the server.

        The --force option will delete the user without asking for confirmation.
      LONGDESC
      option :force, aliases: '-f', type: :boolean
      def delete(username)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        if options[:force]
          delete = true
        else
          print "Delete user #{username}: are you sure? (Y/n): ".colorize(:red)
          delete = STDIN.getc.chr.casecmp('y') == 0
        end
        abort unless delete

        begin
          client.user_delete(username)
        rescue StandardError => ex
          abort "Failed to delete user: #{ex}"
        end
      end
    end

    # 'admin organization' sub-commands
    class AdminOrganization < Thor
      desc 'list', 'List all of the organizations'
      def list
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          orgs = client.org_list
          orgs.each do |org|
            puts org
          end
        rescue StandardError => ex
          abort "Failed to retrieve list of organizations: #{ex}"
        end
      end

      desc 'show NAME', 'Show details of the organization NAME'
      def show(name)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          org = client.org_get(name)

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
          abort "Failed to get user: #{ex}"
        end
      end

      desc 'create NAME OWNER-EMAIL', 'Create a new organization NAME'
      long_desc <<-LONGDESC
        Create an organization NAME with the owner email address EMAIL.
      LONGDESC
      def create(name, email)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          client.org_add(name, email)
        rescue StandardError => ex
          abort "Failed to create new organization: #{ex}"
        end
      end

      desc 'modify NAME', 'Modify the organization NAME'
      long_desc <<-LONGDESC
        Modify the organization NAME.

        The --email option sets the owners email address.

        The --members options sets the list of organization members.

        *WARNING* --members will overwrite the existing list of members, so use with care!
      LONGDESC
      option :email, aliases: '-e'
      option :members, aliases: '-m', type: :array
      def modify(name)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          client.org_modify(name,
                            owner_email: options[:email],
                            members: options[:members])
        rescue StandardError => ex
          abort "Failed to modify organization: #{ex}"
        end
      end

      desc 'delete NAME', 'Delete the organization NAME'
      long_desc <<-LONGDESC
        Delete the organization NAME from the server.

        The --force option will delete the organization without asking for confirmation.
      LONGDESC
      option :force, aliases: '-f', type: :boolean
      def delete(name)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        if options[:force]
          delete = true
        else
          print "Delete organization #{name}: are you sure? (Y/n): ".colorize(:red)
          delete = STDIN.getc.chr.casecmp('y') == 0
        end
        abort unless delete

        begin
          client.org_delete(name)
        rescue StandardError => ex
          abort "Failed to delete organization: #{ex}"
        end
      end
    end

    # 'admin' sub-command
    class Admin < Thor
      desc 'user', 'Manage users'
      subcommand 'user', AdminUser

      desc 'organization', 'Manage organizations'
      subcommand 'organization', AdminOrganization
      map 'org' => :organization
    end
  end
end
