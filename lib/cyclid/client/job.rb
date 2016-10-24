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

module Cyclid
  module Client
    # Job related methods
    module Job
      # Submit a job
      # @param organization [String] Organization name.
      # @param job [String] Raw job data in either JSON or YAML
      # @param type [String] Job data format; either 'json' or 'yaml'
      # @return [Hash] Decoded server response object.
      # @example Submit a job in JSON format
      #   job = File.read('job.json')
      #   job_submit('example', job, 'json')
      # @example Submit a job in YAML format
      #   job = File.read('job.yml')
      #   job_submit('example', job, 'yaml')
      def job_submit(organization, job, type)
        uri = server_uri("/organizations/#{organization}/jobs")
        case type
        when 'yaml'
          res_data = api_raw_post(uri, job, 'application/x-yaml')
        when 'json'
          res_data = api_raw_post(uri, job, 'application/json')
        else
          raise "Unknown job format #{type}"
        end
        @logger.debug res_data

        return res_data
      end

      # Get details of a job
      # @param organization [String] Organization name.
      # @param jobid [Integer] Job ID to retrieve. The ID must be a valid job for the organization.
      # @return [Hash] Decoded server response object.
      # @see #job_status
      # @see #job_log
      def job_get(organization, jobid)
        uri = server_uri("/organizations/#{organization}/jobs/#{jobid}")
        res_data = api_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Get a job status
      # @param organization [String] Organization name.
      # @param jobid [Integer] Job ID to retrieve. The ID must be a valid job for the organization.
      # @return [Hash] Decoded server response object.
      # @see #job_get
      # @see #job_log
      def job_status(organization, jobid)
        uri = server_uri("/organizations/#{organization}/jobs/#{jobid}/status")
        res_data = api_get(uri)
        @logger.debug res_data

        return res_data
      end

      # Get a job log
      # @param organization [String] Organization name.
      # @param jobid [Integer] Job ID to retrieve. The ID must be a valid job for the organization.
      # @return [Hash] Decoded server response object.
      # @see #job_get
      # @see #job_status
      def job_log(organization, jobid)
        uri = server_uri("/organizations/#{organization}/jobs/#{jobid}/log")
        res_data = api_get(uri)
        @logger.debug res_data

        return res_data
      end
    end
  end
end
