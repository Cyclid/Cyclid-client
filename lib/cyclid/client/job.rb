module Cyclid
  module Client
    # Job related methods
    module Job
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
