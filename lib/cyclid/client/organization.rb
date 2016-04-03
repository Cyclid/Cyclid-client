module Cyclid
  module Client
    # Organization related methods
    module Organization
      # Retrieve the list of organizations from a server
      def org_list
        uri = server_uri('/organizations')
        req = sign_request(Net::HTTP::Get.new(uri), uri)

        http = Net::HTTP.new(uri.hostname, uri.port)
        res = http.request(req)

        res_data = parse_response(res)
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
