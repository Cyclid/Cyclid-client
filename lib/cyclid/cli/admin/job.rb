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
  module Cli
    # 'admin job' sub-commands
    class AdminJob < Thor
      desc 'list NAME', 'List all jobs for the organization NAME'
      def list(name)
        stats = client.job_stats(name)
        all = client.job_list(name, limit: stats['total'])
        jobs = all['records']

        jobs.each do |job|
          puts 'Name: '.colorize(:cyan) + (job['job_name'] || '')
          puts "\tJob: ".colorize(:cyan) + job['id'].to_s
          puts "\tVersion: ".colorize(:cyan) + (job['job_version'] || '')
        end
      rescue StandardError => ex
        STDERR.puts ex.backtrace
        abort "Failed to get job list: #{ex}"
      end

      desc 'stats NAME', 'Show statistics about jobs for the organization NAME'
      def stats(name)
        stats = client.job_stats(name)

        puts 'Total jobs: '.colorize(:cyan) + stats['total'].to_s
      rescue StandardError => ex
        abort "Failed to get job list: #{ex}"
      end
    end
  end
end
