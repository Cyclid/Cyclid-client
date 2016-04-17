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

require 'thor'
require 'require_all'

require_rel 'cli/*.rb'
require 'cyclid/client'

# Add some helpers to the Thor base class
class Thor
  private

  def client
    @client ||= Cyclid::Client::Tilapia.new(options[:config], debug?)
  end

  def debug?
    options[:debug] ? Logger::DEBUG : Logger::FATAL
  end
end

module Cyclid
  module Cli
    CYCLID_CONFIG_DIR = File.join(ENV['HOME'], '.cyclid')
    CYCLID_CONFIG_PATH = File.join(CYCLID_CONFIG_DIR, 'config')

    # Top level Thor-based CLI
    class Command < Thor
      class_option :config, aliases: '-c', type: :string, default: CYCLID_CONFIG_PATH
      class_option :debug, aliases: '-d', type: :boolean, default: false

      desc 'admin', 'Administrator commands'
      subcommand 'admin', Admin

      desc 'user', 'Manage users'
      subcommand 'user', User

      desc 'organization', 'Manage organizations'
      subcommand 'organization', Organization
      map 'org' => :organization

      desc 'job', 'Manage jobs'
      subcommand 'job', Job

      desc 'secret', 'Manage secrets'
      subcommand 'secret', Secret
    end
  end
end
