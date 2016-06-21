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
    # Authentication related methods
    module Auth
      # Retrieve a JWT token from the server.
      # @param claims [Hash] additional JWT claims to append to the token.
      # @return [Hash] Decoded server response object.
      # @example Request a simple token
      #   token_data = token_get
      # @example Request a token with a CSRF injected into the claims
      #   token_data = token_get(csrf: 'abcdef0123456789')
      def token_get(claims = {})
        uri = server_uri('/token')
        res_data = api_json_post(uri, claims.to_json)
        @logger.debug res_data

        return res_data
      end
    end
  end
end
