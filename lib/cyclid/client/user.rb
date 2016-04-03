module Cyclid
  module Client
    module User 
      def user_list
        uri = server_uri('/users')
        req = sign_request(Net::HTTP::Get.new(uri), uri)

        http = Net::HTTP.new(uri.hostname, uri.port)
        http.set_debug_output(@logger) if @logger.level == Logger::DEBUG
        res = http.request(req)

        res_data = parse_response(res)

        users = []
        res_data.each do |item|
          users << item['username']
        end

        return users
      rescue StandardError => ex
        abort "Failed to retrieve list of users: #{ex}"
      end
    end
  end
end
