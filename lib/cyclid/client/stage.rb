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
    # Stage related methods
    module Stage
      # Retrieve the list of stages from a server
      def stage_list(organization)
        uri = server_uri("/organizations/#{organization}/stages")
        res_data = signed_get(uri)
        @logger.debug res_data

        stages = []
        res_data.each do |item|
          stages << { name: item['name'], version: item['version'] }
        end

        return stages
      end

      # Get details of a stage
      def stage_get(organization, name)
        uri = server_uri("/organizations/#{organization}/stages/#{name}")
        res_data = signed_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Create a stage
      def stage_create(organization, stage)
        uri = server_uri("/organizations/#{organization}/stages")
        res_data = signed_json_post(uri, stage)
        @logger.debug res_data

        return res_data
      end

      # Modify a stage. Stages are actually immutable; this actually creates a
      # new version of a stage.
      def stage_modify(organization, stage)
        uri = server_uri("/organizations/#{organization}/stages")
        res_data = signed_json_post(uri, stage)
        @logger.debug res_data

        return res_data
      end
    end
  end
end
