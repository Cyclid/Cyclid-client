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
    # Commands for managing per. organization configuration
    class Config < Thor
      desc 'show TYPE PLUGIN', 'Show a plugin configuration'
      def show(type, plugin)
        plugin_data = client.org_config_get(client.config.organization, type, plugin)

        config = plugin_data['config']
        schema = plugin_data['schema']
        schema.each do |setting|
          name = setting['name']
          type = setting['type']

          case type
          when 'string'
            data = config[name] || 'Not set'
            puts "#{setting['description']}: ".colorize(:cyan) + data
          when 'hash-list'
            puts setting['description'].colorize(:cyan)
            data = config[name]
            if data.empty?
              puts "\tNone"
            else
              data.each do |item|
                item.each do |k,v|
                  puts "\t#{k}: #{v}"
                end
              end
            end
          else
            #raise "unknown schema type #{type}"
          end
        end
      rescue StandardError => ex
        abort "Failed to get plugin configuration: #{ex}"
      end
    end
  end
end 
