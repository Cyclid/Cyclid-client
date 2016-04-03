# Cyclid top level module
module Cyclid
  module Cli
    # 'user' sub-command
    class User < Thor
      desc 'list', 'List all of the users'
      def list
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          users = client.user_list
          users.each do |user|
            STDOUT.puts user
          end
        rescue StandardError => ex
          abort "Failed to retrieve list of users: #{ex}"
        end
      end

      desc 'add USERNAME EMAIL [<password>] [<secret>]', 'Create a new user USERNAME'
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
      def add(username, email)
        client = Cyclid::Client::Tilapia.new(options[:config], debug?)

        begin
          client.user_add(username, email, options[:password], options[:secret])
        rescue StandardError => ex
          abort "Failed to create new user: #{ex}"
        end
      end
    end
  end
end
