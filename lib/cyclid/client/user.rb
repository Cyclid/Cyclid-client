require 'bcrypt'

module Cyclid
  module Client
    # User related methods
    module User
      # Retrieve the list of users from a server
      def user_list
        uri = server_uri('/users')
        res_data = signed_get(uri)
        @logger.debug res_data

        users = []
        res_data.each do |item|
          users << item['username']
        end

        return users
      end

      # Get details of a specific user
      def user_get(username)
        uri = server_uri("/users/#{username}")
        res_data = signed_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Create a new user
      def user_add(username, email, password = nil, secret = nil)
        # Create the user object
        user = { 'username' => username, 'email' => email }

        # Add the HMAC secret if one was supplied
        user['secret'] = secret unless secret.nil?

        # Encrypt & add the password if one was supplied
        user['password'] = BCrypt::Password.create(password).to_s unless password.nil?

        @logger.debug user

        # Sign & send the request
        uri = server_uri('/users')
        res_data = signed_json_post(uri, user)
        @logger.debug res_data

        return res_data
      end

      # Modify a user
      def user_modify(username, args)
        # Create the user object
        user = {}

        # Add the email address if one was supplied
        user['email'] = args[:email] if args.key? :email and args[:email]

        # Add the HMAC secret if one was supplied
        user['secret'] = args[:secret] if args.key? :secret and args[:secret]

        # Encrypt & add the password if one was supplied
        user['password'] = BCrypt::Password.create(args[:password]).to_s \
          if args.key? :password and args[:password]

        @logger.debug user

        # Sign & send the request
        uri = server_uri("/users/#{username}")
        res_data = signed_json_put(uri, user)
        @logger.debug res_data

        return res_data
      end

      # Delete a user
      def user_delete(username)
        uri = server_uri("/users/#{username}")
        res_data = signed_delete(uri)
        @logger.debug res_data

        return res_data
      end
    end
  end
end
