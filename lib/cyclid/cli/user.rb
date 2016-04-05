require 'colorize'

# Cyclid top level module
module Cyclid
  module Cli
    # 'user' sub-command
    class User < Thor
      desc 'show', 'Show your user details'
      def show
        user = client.user_get(client.config.username)

        # Pretty print the user details
        puts 'Username: '.colorize(:cyan) + user['username']
        puts 'Email: '.colorize(:cyan) + user['email']
        puts 'Organizations'.colorize(:cyan)
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

      desc 'modify', 'Modify your user'
      long_desc <<-LONGDESC
        Modify your user details.

        The --email option sets your email address.

        The --password option sets an encrypted password for HTTP Basic authentication and Cyclid
        UI console logins.

        The --secret option sets a shared secret which is used for signing Cyclid API requests.
      LONGDESC
      option :email, aliases: '-e'
      option :password, aliases: '-p'
      option :secret, aliases: '-s'
      def modify
        client.user_modify(client.config.username,
                           email: options[:email],
                           password: options[:password],
                           secret: options[:secret])
      rescue StandardError => ex
        abort "Failed to modify user: #{ex}"
      end

      desc 'passwd', 'Change your password'
      def passwd
        # Get the new password
        print 'Password: '
        password = STDIN.noecho(&:gets).chomp
        print "\nConfirm password: "
        confirm = STDIN.noecho(&:gets).chomp
        print "\n"
        abort 'Passwords do not match' unless password == confirm

        # Modify the user with the new password
        begin
          client.user_modify(client.config.username, password: password)
        rescue StandardError => ex
          abort "Failed to modify user: #{ex}"
        end
      end
    end
  end
end
