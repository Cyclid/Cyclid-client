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
      def org_list
        uri = server_uri('/organizations')
        res_data = signed_get(uri)
        @logger.debug res_data

        orgs = []
        res_data.each do |item|
          orgs << item['name']
        end

        return orgs
      end

      # Get details of a specific organization
      def org_get(name)
        uri = server_uri("/organizations/#{name}")
        res_data = signed_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Create a new organization
      def org_add(name, email)
        # Create the organization object
        org = { 'name' => name, 'owner_email' => email }
        @logger.debug org

        # Sign & send the request
        uri = server_uri('/organizations')
        res_data = signed_json_post(uri, org)
        @logger.debug res_data

        return res_data
      end

      # Modify an organization
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
        res_data = signed_json_put(uri, org)
        @logger.debug res_data

        return res_data
      end

      # Get details of an organization member
      def org_user_get(name, username)
        uri = server_uri("/organizations/#{name}/members/#{username}")
        res_data = signed_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Modify the permissions for an organization member
      def org_user_permissions(name, username, permissions)
        perms = { 'permissions' => permissions }

        @logger.debug perms

        uri = server_uri("/organizations/#{name}/members/#{username}")
        res_data = signed_json_put(uri, perms)
        @logger.debug res_data

        return res_data
      end

      # Get an organization configuration for a plugin
      def org_config_get(name, type, plugin)
        uri = server_uri("/organizations/#{name}/configs/#{type}/#{plugin}")
        res_data = signed_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Delete an organization
      def org_delete(name)
        uri = server_uri("/organizations/#{name}")
        res_data = signed_delete(uri)
        @logger.debug res_data

        return res_data
      end
    end
  end
end
