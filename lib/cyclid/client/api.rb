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

require 'uri'
require 'net/http'

module Cyclid
  # Cyclid client methods
  module Client
    # Client API request methods
    module Api
      # Base class for API request implementations
      class Base
        # Add authentication details & perform a GET request
        def api_get(uri)
          req = authenticate_request(Net::HTTP::Get.new(uri), uri)

          api_request(uri, req)
        end

        # Add authentication details perform a POST request with a pre-formatted body
        def api_raw_post(uri, data, content_type)
          unsigned = Net::HTTP::Post.new(uri)
          unsigned.content_type = content_type
          unsigned.body = data

          req = authenticate_request(unsigned, uri)

          api_request(uri, req)
        end

        # Add authentication details perform a POST request with a JSON body
        def api_json_post(uri, data)
          json = Oj.dump(data)
          api_raw_post(uri, json, 'application/json')
        end

        # Add authentication details perform a POST request with a YAML body
        def api_yaml_post(uri, data)
          yaml = YAML.dump(data)
          api_raw_post(uri, yaml, 'application/x-yaml')
        end

        # Add authentication details perform a PUT request with a JSON body
        def api_json_put(uri, data)
          unsigned = Net::HTTP::Put.new(uri)
          unsigned.content_type = 'application/json'
          unsigned.body = Oj.dump(data)

          req = authenticate_request(unsigned, uri)

          api_request(uri, req)
        end

        # Add authentication details perform a DELETE request
        def api_delete(uri)
          req = authenticate_request(Net::HTTP::Delete.new(uri), uri)

          api_request(uri, req)
        end

        # Perform an API HTTP request & return the parsed response body
        def api_request(uri, req)
          http = Net::HTTP.new(uri.hostname, uri.port)
          res = http.request(req)

          parse_response(res)
        end

        # Parse, validate & handle response data
        def parse_response(res)
          response_data = Oj.load(res.body)

          # Return immediately if the response was an HTTP 200 OK
          return response_data if res.code == '200'

          @logger.info "server request failed with error ##{res.code}: \
                       #{response_data['description']}"
          raise response_data['description']
        rescue Oj::ParseError => ex
          @logger.debug "body: #{res.body}\n#{ex}"
          raise 'failed to decode server response body'
        end

        # The API does not support non-authenticated requests, so this method
        # must be implemented.
        def authenticate_request(request, uri)
          raise NotImplementedError
        end
      end
    end
  end
end

require 'cyclid/client/api/hmac'
