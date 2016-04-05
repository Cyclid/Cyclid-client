require 'cyclid/constants'

module Cyclid
  module Cli
    # 'job' sub-command
    class Job < Thor
      desc 'show JOBID', 'Show details of a job'
      def show(jobid)
        job = client.job_get(client.config.organization, jobid)

        status_id = job['status']
        status = Cyclid::API::Constants::JOB_STATUSES[status_id]

        started = job['started'].nil? ? nil : Time.parse(job['started'])
        ended = job['ended'].nil? ? nil : Time.parse(job['ended'])

        # Pretty-print the job details (without the log)
        puts 'Job: '.colorize(:cyan) + job['id'].to_s
        puts 'Name: '.colorize(:cyan) + (job['job_name'] || '')
        puts 'Version: '.colorize(:cyan) + (job['job_version'] || '')
        puts 'Started: '.colorize(:cyan) + (started ? started.asctime : '')
        puts 'Ended: '.colorize(:cyan) + (ended ? ended.asctime : '')
        puts 'Status: '.colorize(:cyan) + status
      rescue StandardError => ex
        abort "Failed to get job status: #{ex}"
      end

      desc 'status JOBID', 'Show the status of a job'
      def status(jobid)
        job_status = client.job_status(client.config.organization, jobid)

        status_id = job_status['status']
        status = Cyclid::API::Constants::JOB_STATUSES[status_id]

        # Pretty-print the job status
        puts 'Status: '.colorize(:cyan) + status
      rescue StandardError => ex
        abort "Failed to get job status: #{ex}"
      end

      desc 'log JOBID', 'Show the job log'
      def log(jobid)
        job_log = client.job_log(client.config.organization, jobid)

        puts job_log['log']
      rescue StandardError => ex
        abort "Failed to get job log: #{ex}"
      end
    end
  end
end
