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
    end
  end
end
