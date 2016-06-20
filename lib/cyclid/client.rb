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
require 'cyclid/hmac'

require 'cyclid/client/http'
require 'cyclid/client/user'
require 'cyclid/client/organization'
require 'cyclid/client/job'
require 'cyclid/client/stage'

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

      # @param config_path [String] Fully qualified path to the configuration file
      # @param log_level [FixNum] Logger output level
      def initialize(config_path, log_level = Logger::FATAL)
        @config = Config.new(path: config_path)

        @logger = Logger.new(STDERR)
        @logger.level = log_level

        @api = Http::HMAC.new(@config)
      end

      include User
      include Organization
      include Job
      include Stage

      private

      include Http

      def method_missing(method, *args, &block)
        @api.send(method, *args, &block)
      end
    end
  end
end
