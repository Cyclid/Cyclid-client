# frozen_string_literal: true

# Copyright 2017 Liqwyd Ltd.
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
require 'json'
require 'cyclid/linter'

module Cyclid
  module Cli
    # Verify by fetching Stages from a remote server
    class RemoteVerifier < Cyclid::Linter::Verifier
      def initialize(args)
        @client = args[:client]

        super
      end

      # Find a Stage by it's name on a remote server
      def stage_exists?(name)
        @client.stage_get(@client.config.organization, name)

        Bertrand::EXIST
      rescue StandardError => ex
        if ex.to_s == 'stage does not exist'
          Bertrand::NOT_EXIST
        else
          Bertrand::UNKNOWN
        end
      end
    end
  end
end
