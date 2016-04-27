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
    # Job related methods
    module Job
      # Submit a job
      def job_submit(organization, job, type)
        uri = server_uri("/organizations/#{organization}/jobs")
        case type
        when 'yaml'
          res_data = signed_raw_post(uri, job, 'application/x-yaml')
        when 'json'
          res_data = signed_raw_post(uri, job, 'application/json')
        else
          raise "Unknown job format #{type}"
        end
        @logger.debug res_data

        return res_data
      end

      # Get details of a job
      def job_get(organization, jobid)
        uri = server_uri("/organizations/#{organization}/jobs/#{jobid}")
        res_data = signed_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Get a job status
      def job_status(organization, jobid)
        uri = server_uri("/organizations/#{organization}/jobs/#{jobid}/status")
        res_data = signed_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Get a job log
      def job_log(organization, jobid)
        uri = server_uri("/organizations/#{organization}/jobs/#{jobid}/log")
        res_data = signed_get(uri)
        @logger.debug res_data

        return res_data
      end
    end
  end
end
