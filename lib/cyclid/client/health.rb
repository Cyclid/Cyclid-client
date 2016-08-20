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
    # Health-check related methods
    module Health
      # Ping the API server.
      # @return [Boolean] True if the API server is healthy, false if it is unhealthy.
      def health_ping
        uri = server_uri('/health/status')

        # We need to do without the API helpers as the health endpoint won't
        # return any data, just an HTTP status
        req = authenticate_request(Net::HTTP::Get.new(uri), uri)
        http = Net::HTTP.new(uri.hostname, uri.port)
        res = http.request(req)

        return res.code == '200'
      end
    end
  end
end
