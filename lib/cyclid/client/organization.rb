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
