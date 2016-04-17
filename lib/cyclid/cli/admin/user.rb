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

module Cyclid
  module Cli
    # 'admin user' sub-commands
    class AdminUser < Thor
      desc 'list', 'List all of the users'
      def list
        users = client.user_list
        users.each do |user|
          puts user
        end
      rescue StandardError => ex
        abort "Failed to retrieve list of users: #{ex}"
      end

      desc 'show USERNAME', 'Show details of the user USERNAME'
      def show(username)
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
        client.user_add(username, email, options[:password], options[:secret])
      rescue StandardError => ex
        abort "Failed to create new user: #{ex}"
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
        client.user_modify(username,
                           email: options[:email],
                           password: options[:password],
                           secret: options[:secret])
      rescue StandardError => ex
        abort "Failed to modify user: #{ex}"
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
  end
end
