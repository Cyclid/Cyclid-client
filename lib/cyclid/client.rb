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

require 'securerandom'
require 'oj'
require 'yaml'
require 'logger'

require 'cyclid/config'
require 'cyclid/auth_methods'

require 'cyclid/client/api'
require 'cyclid/client/user'
require 'cyclid/client/organization'
require 'cyclid/client/job'
require 'cyclid/client/stage'
require 'cyclid/client/auth'
require 'cyclid/client/health'

module Cyclid
  # Cyclid client methods
  module Client
    # Tilapia is the standard Cyclid Ruby client. It provides an inteligent
    # programmable API on top of the standard Cyclid REST API, complete with
    # automatic signing of HTTP requests and HTTP error handling.
    #
    # The client provides interfaces for managing Users, Organizations, Stages
    # & Jobs. Refer to the documentation for those modules for more information.
    #
    # In case you're wondering, this class required a name: it couldn't be
    # 'Cyclid' and it couldn't be 'Client'. Tilapia are a common type of
    # Cichlid...
    class Tilapia
      attr_reader :config, :logger
      # @!attribute [r] config
      #   @return [Config] Client configuration object
      # @!attribute [r] logger
      #   @return [Logger] Client logger object

      # @param [Hash] options
      # @option options [String] :config_path Fully qualified path to the configuration file
      # @option options [FixNum] :log_level Logger output level
      def initialize(options)
        @config = Config.new(options)

        # Create a logger
        log_level = options[:log_level] || Logger::FATAL
        @logger = Logger.new(STDERR)
        @logger.level = log_level

        # Select the API methods to use
        @api = case @config.auth
               when AuthMethods::AUTH_NONE
                 Api::None.new(@config, @logger)
               when AuthMethods::AUTH_HMAC
                 Api::Hmac.new(@config, @logger)
               when AuthMethods::AUTH_BASIC
                 Api::Basic.new(@config, @logger)
               when AuthMethods::AUTH_TOKEN
                 Api::Token.new(@config, @logger)
               end
      end

      include User
      include Organization
      include Job
      include Stage
      include Auth
      include Health

      private

      # Build a URI for the configured server & required resource
      def server_uri(path)
        scheme = @config.tls ? URI::HTTPS : URI::HTTP
        scheme.build(host: @config.server,
                     port: @config.port,
                     path: path)
      end

      def method_missing(method, *args, &block) # rubocop:disable Style/MethodMissing
        @api.send(method, *args, &block)
      end
    end

    include AuthMethods
  end
end
