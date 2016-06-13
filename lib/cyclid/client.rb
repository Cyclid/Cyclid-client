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

require 'securerandom'
require 'oj'
require 'yaml'
require 'logger'
require 'uri'
require 'net/http'

require 'cyclid/config'
require 'cyclid/hmac'

require 'cyclid/client/user'
require 'cyclid/client/organization'
require 'cyclid/client/job'
require 'cyclid/client/stage'

module Cyclid
  # Cyclid client methods
  module Client
    # In case you're wondering, this class required a name: it couldn't be
    # 'Cyclid' and it couldn't be 'Client'. Tilapia are a common type of
    # Cichlid...
    class Tilapia
      attr_reader :config, :logger

      def initialize(config_path, log_level = Logger::FATAL)
        @config = Config.new(config_path)

        @logger = Logger.new(STDERR)
        @logger.level = log_level
      end

      include User
      include Organization
      include Job
      include Stage

      private

      # Build a URI for the configured server & required resource
      def server_uri(path)
        URI::HTTP.build(host: @config.server,
                        port: @config.port,
                        path: path)
      end

      # Sign & perform a GET request
      def signed_get(uri)
        req = sign_request(Net::HTTP::Get.new(uri), uri)

        http = Net::HTTP.new(uri.hostname, uri.port)
        res = http.request(req)

        parse_response(res)
      end

      # Sign & perform a POST request with a pre-formatted body
      def signed_raw_post(uri, data, content_type)
        unsigned = Net::HTTP::Post.new(uri)
        unsigned.content_type = content_type
        unsigned.body = data

        req = sign_request(unsigned, uri)

        http = Net::HTTP.new(uri.hostname, uri.port)
        res = http.request(req)

        parse_response(res)
      end

      # Sign & perform a POST request with a JSON body
      def signed_json_post(uri, data)
        json = Oj.dump(data)
        signed_raw_post(uri, json, 'application/json')
      end

      # Sign & perform a POST request with a YAML body
      def signed_yaml_post(uri, data)
        yaml = YAML.dump(data)
        signed_raw_post(uri, yaml, 'application/x-yaml')
      end

      # Sign & perform a PUT request with a JSON body
      def signed_json_put(uri, data)
        unsigned = Net::HTTP::Put.new(uri)
        unsigned.content_type = 'application/json'
        unsigned.body = Oj.dump(data)

        req = sign_request(unsigned, uri)

        http = Net::HTTP.new(uri.hostname, uri.port)
        res = http.request(req)

        parse_response(res)
      end

      # Sign & perform a DELETE request
      def signed_delete(uri)
        req = sign_request(Net::HTTP::Delete.new(uri), uri)

        http = Net::HTTP.new(uri.hostname, uri.port)
        res = http.request(req)

        parse_response(res)
      end

      # Sign the request with HMAC
      def sign_request(request, uri)
        signer = Cyclid::HMAC::Signer.new

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
                                      auth_header_format: '%{auth_scheme} %{username}:%{signature}',
                                      username: @config.username,
                                      nonce: nonce,
                                      method: method)

        headers[0].each do |k, v|
          request[k] = v
        end

        return request
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
    end
  end
end
