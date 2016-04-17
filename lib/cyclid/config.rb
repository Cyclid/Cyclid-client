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

require 'yaml'

module Cyclid
  module Client
    # Cyclid client per-organization configuration
    class Config
      attr_reader :server, :port, :organization, :username, :secret, :path

      def initialize(path)
        @config = YAML.load_file(path)

        @server = @config['server']
        @port = @config['port'] || 80
        @organization = @config['organization']
        @username = @config['username']
        @secret = @config['secret']
      rescue StandardError => ex
        abort "Failed to load configuration file #{path}: #{ex}"
      end
    end
  end
end
