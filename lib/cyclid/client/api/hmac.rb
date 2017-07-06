# frozen_string_literal: true

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

require 'cyclid/hmac'

module Cyclid
  # Cyclid client methods
  module Client
    # Client API HTTP methods
    module Api
      # HMAC signed HTTP methods
      class Hmac < Base
        # Sign the request with HMAC
        def authenticate_request(request, uri)
          algorithm = 'sha256'
          signer = Cyclid::HMAC::Signer.new(algorithm)

          method = if request.is_a? Net::HTTP::Get
                     'GET'
                   elsif request.is_a? Net::HTTP::Post
                     'POST'
                   elsif request.is_a? Net::HTTP::Put
                     'PUT'
                   elsif request.is_a? Net::HTTP::Delete
                     'DELETE'
                   else
                     raise "invalid request method #{request.inspect}"
                   end

          nonce = SecureRandom.hex
          headers = signer.sign_request(uri.path,
                                        @config.secret,
                                        auth_header_format: '%<auth_scheme>s %<username>s:%<signature>s', # rubocop:disable Metrics/LineLength
                                        username: @config.username,
                                        nonce: nonce,
                                        method: method)

          headers[0].each do |k, v|
            request[k] = v
          end
          request['X-HMAC-Algorithm'] = algorithm

          return request
        end
      end
    end
  end
end
