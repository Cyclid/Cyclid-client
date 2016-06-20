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
  module Client
    # Organization related methods
    module Organization
      # Retrieve the list of organizations from a server
      # @return [Array] List of organization names.
      def org_list
        uri = server_uri('/organizations')
        res_data = api_get(uri)
        @logger.debug res_data

        orgs = []
        res_data.each do |item|
          orgs << item['name']
        end

        return orgs
      end

      # Get details of a specific organization
      # @param name [String] organization name.
      # @return [Hash] Decoded server response object.
      def org_get(name)
        uri = server_uri("/organizations/#{name}")
        res_data = api_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Create a new organization. The organization is created without any
      # members; use org_modify to add a set of users to the organization
      # after it has been created.
      #
      # @param name [String] organization name.
      # @param email [String] organization owners email address.
      # @return [Hash] Decoded server response object.
      # @example Create a new organization 'example'
      #   new_org = org_add('example', 'admin@example.com')
      # @see #org_modify
      def org_add(name, email)
        # Create the organization object
        org = { 'name' => name, 'owner_email' => email }
        @logger.debug org

        # Sign & send the request
        uri = server_uri('/organizations')
        res_data = api_json_post(uri, org)
        @logger.debug res_data

        return res_data
      end

      # Modify an organization. Only the owner email address and organization
      # members can be changed; you can not change the name of an organization
      # once it has been created.
      #
      # @note Setting the organization members will *overwrite* the existing
      #   set; you should ensure the set of members is complete before you set it.
      # @param name [String] organization name.
      # @param args [Hash] options to modify the organization.
      # @option args [String] owner_email Organization owners email address.
      # @option args [Array] members Set of users who will be organization members.
      # @return [Hash] Decoded server response object.
      # @see #org_add
      # @see #org_delete
      def org_modify(name, args)
        # Create the organization object
        org = {}

        # Add the owner email address if one was supplied
        org['owner_email'] = args[:owner_email] \
          if args.key? :owner_email and args[:owner_email]

        # Add the list of members if it was supplied
        org['users'] = args[:members] \
          if args.key? :members and args[:members]

        @logger.debug org

        # Sign & send the request
        uri = server_uri("/organizations/#{name}")
        res_data = api_json_put(uri, org)
        @logger.debug res_data

        return res_data
      end

      # Get details of an organization member
      # @param name [String] organization name.
      # @param username [String] member username.
      # @return [Hash] Decoded server response object.
      # @see User#user_get
      def org_user_get(name, username)
        uri = server_uri("/organizations/#{name}/members/#{username}")
        res_data = api_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Modify the permissions for an organization member
      # @param name [String] organization name.
      # @param username [String] member username.
      # @param permissions [Hash] permissions to apply to the member.
      # @option permissions [Boolean] admin organization 'admin' permission.
      # @option permissions [Boolean] write organization 'write' permission.
      # @option permissions [Boolean] read organization 'read' permission.
      # @return [Hash] Decoded server response object.
      # @see #org_modify
      # @example Give the user 'leslie' read & write permission to the 'example' organization
      #   perms = {admin: false, write: true, read: true}
      #   org_user_permissions('example', 'leslie', perms)
      def org_user_permissions(name, username, permissions)
        perms = { 'permissions' => permissions }

        @logger.debug perms

        uri = server_uri("/organizations/#{name}/members/#{username}")
        res_data = api_json_put(uri, perms)
        @logger.debug res_data

        return res_data
      end

      # Get a plugin configuration for an organization.
      # @param name [String] organization name.
      # @param type [String] plugin 'type'
      # @param plugin [String] plugin name.
      # @return [Hash] Decoded server response object.
      # @see #org_config_set
      # @example Get the plugin config & schema for the 'foo' 'api' type plugin, for the 'example' organization
      #   org_config_get('example', 'api', 'foo')
      def org_config_get(name, type, plugin)
        uri = server_uri("/organizations/#{name}/configs/#{type}/#{plugin}")
        res_data = api_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Update a plugin configuration for an organization.
      # @param name [String] organization name.
      # @param type [String] plugin 'type'
      # @param plugin [String] plugin name.
      # @param config [Hash] plugin configuration data.
      # @return [Hash] Decoded server response object.
      # @see #org_config_get
      def org_config_set(name, type, plugin, config)
        uri = server_uri("/organizations/#{name}/configs/#{type}/#{plugin}")
        res_data = api_json_put(uri, config)
        @logger.debug res_data

        return res_data
      end

      # Delete an organization
      # @note The API does not currently support deleting an organization and
      #   this method will always fail.
      # @param name [String] organization name.
      # @return [Hash] Decoded server response object.
      # @see #org_add
      def org_delete(name)
        uri = server_uri("/organizations/#{name}")
        res_data = api_delete(uri)
        @logger.debug res_data

        return res_data
      end
    end
  end
end
