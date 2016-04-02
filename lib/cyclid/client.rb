require 'securerandom'
require 'oj'
require 'logger'

require 'cyclid/config'
require 'cyclid/hmac'

module Cyclid
  module Client
    # In case you're wondering, this class required a name: it couldn't be
    # 'Cyclid' and it couldn't be 'Client'. Tilapia are a common type of
    # Cichlid...
    class Tilapia
      attr_reader :config, :logger

      def initialize(config_path, log_level=Logger::FATAL)
        @config = Config.new(config_path)

        @logger = Logger.new(STDERR)
        @logger.level = log_level
      end

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

      private

      # Build a URI for the configured server & required resource
      def server_uri(path)
        URI::HTTP.build(host: @config.server,
                        port: @config.port,
                        path: path)
      end

      # Sign the request with HMAC
      def sign_request(request, uri)
        signer = Cyclid::HMAC::Signer.new

        nonce = SecureRandom.hex
        headers = signer.sign_request(uri.path,
                                      @config.secret,
                                      auth_header_format: '%{auth_scheme} %{username}:%{signature}',
                                      username: @config.username,
                                      nonce: nonce)

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

        raise "Server request failed with error ##{res.code}: #{response_data['message']}"
      rescue Oj::ParseError => ex
        @logger.debug ex
        raise 'failed to decode server response body'
      end
    end
  end
end
