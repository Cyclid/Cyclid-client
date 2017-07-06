# frozen_string_literal: true

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

# Cyclid top level module
module Cyclid
  module Cli
    # 'user' sub-command
    class User < Thor
      desc 'show', 'Show your user details'
      def show
        user = client.user_get(client.config.username)

        # Pretty print the user details
        Formatter.colorize 'Username', user['username']
        Formatter.colorize 'Name', (user['name'] || '')
        Formatter.colorize 'Email', user['email']
        Formatter.colorize 'Organizations'
        if user['organizations'].any?
          user['organizations'].each do |org|
            Formatter.puts "\t#{org}"
          end
        else
          Formatter.puts "\tNone"
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

      desc 'authenticate', 'Authenticate your client with a server'
      long_desc <<-LONGDESC
        Authenticate against a Cyclid server with your username & password and
        create your client configuration files.

        The --server option sets the Cyclid server URL. The default is 'https://api.cyclid.io'

        The --username option sets your username to authenticate with.
      LONGDESC

      option :server, aliases: '-s'
      option :username, aliases: '-u'
      def authenticate
        url = options[:server] || 'https://api.cyclid.io'
        username = options[:username]

        # Get the username if one wasn't provided
        if username.nil?
          print 'Username: '
          username = STDIN.gets.chomp
        end

        # Get the users password
        print 'Password: '
        password = STDIN.noecho(&:gets).chomp
        puts

        # Create a client that can authenticate with HTTP BASIC
        Formatter.colorize "Authenticating #{username} with #{url}"

        basic_client = Cyclid::Client::Tilapia.new(auth: Cyclid::Client::AuthMethods::AUTH_BASIC,
                                                   url: url,
                                                   username: username,
                                                   password: password,
                                                   log_level: debug?)

        # Get the user information
        user = basic_client.user_get(username)

        # Ensure the configuration directory exists
        Dir.mkdir(CYCLID_CONFIG_DIR, 0o700) unless Dir.exist? CYCLID_CONFIG_DIR

        # Generate a configuration file for each organization
        user['organizations'].each do |org|
          Formatter.colorize "Creating configuration file for organization #{org}"

          org_config = File.new(File.join(CYCLID_CONFIG_DIR, org), 'w+', 0o600)
          org_config.write "url: #{url}\n"
          org_config.write "organization: #{org}\n"
          org_config.write "username: #{username}\n"
          org_config.write "secret: #{user['secret']}\n"
        end
      rescue StandardError => ex
        abort "Failed to authenticate user: #{ex}"
      end
    end
  end
end
