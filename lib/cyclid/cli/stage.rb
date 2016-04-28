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
    # 'stage' sub-command
    class Stage < Thor
      desc 'list', 'List the defined stages'
      def list
        stages = client.stage_list(client.config.organization)
        stages.each do |stage|
          puts "#{stage[:name]} v#{stage[:version]}"
        end
      rescue StandardError => ex
        abort "Failed to get stages: #{ex}"
      end

      desc 'show NAME', 'Show details of a stage'
      def show(name)
        stages = client.stage_get(client.config.organization, name)

        # Pretty print the stage details
        stages.each do |stage|
          puts 'Name: '.colorize(:cyan) + stage['name']
          puts 'Version: '.colorize(:cyan) + stage['version']
          puts 'Steps'.colorize(:cyan)
          stage['steps'].each do |step|
            puts "\t\tAction: ".colorize(:cyan) + step['action']
            step.delete('action')
            step.each do |k, v|
              puts "\t\t#{k.capitalize}: ".colorize(:cyan) + v.to_s
            end
          end
        end
      rescue StandardError => ex
        abort "Failed to get stage: #{ex}"
      end

      desc 'create FILENAME', 'Create a new stage from a file'
      long_desc <<-LONGDESC
        Create a new stage. FILENAME should be the path to a valid Cyclid stage definition, in
        either YAML or JSON format.

        You can create multiple versions of a stage with the same name. You can either set the
        version in the stage definition itself or use the --version option.

        Cyclid will attempt to detect the format of the file automatically. You can force the
        parsing format using either the --yaml or --json options.

        The --yaml option causes the file to be parsed as YAML.

        The --json option causes the file to be parsed as JSON.
      LONGDESC
      option :yaml, aliases: '-y'
      option :json, aliases: '-j'
      option :version, aliases: '-v'
      def create(filename)
        stage_file = File.expand_path(filename)
        raise 'Cannot open file' unless File.exist?(stage_file)

        stage_type = if options[:yaml]
                       'yaml'
                     elsif options[:json]
                       'json'
                     else
                       # Detect format
                       match = stage_file.match(/\A.*\.(json|yml|yaml)\z/)
                       match[1]
                     end
        stage_type = 'yaml' if stage_type == 'yml'

        # Do a client-side sanity check by attempting to parse the file; it
        # will fail-fast if the file has a syntax error
        stage = File.read(stage_file)
        stage_data = if stage_type == 'yaml'
                       YAML.load(stage)
                     elsif stage_type == 'json'
                       JSON.parse(stage)
                     else
                       raise 'Unknown or unsupported file type'
                     end

        # Inject the version if it was passed on the command line
        stage_data['version'] = options[:version] if options[:version]

        client.stage_create(client.config.organization, stage_data)
      rescue StandardError => ex
        abort "Failed to create stage: #{ex}"
      end

      desc 'edit NAME', 'Edit a stage definition'
      long_desc <<-LONGDESC
        Edit a stage. Individual stages are immutable, but you may create a new
        version of an existing stage using this command.
      LONGDESC
      def edit(name)
        stages = client.stage_get(client.config.organization, name)

        # XXX This is a hack. The API returns all stages from this endpoint;
        # we might need to add or extend the API to return "latest" only.
        stage = stages.last

        stage = invoke_editor(stage)
        client.stage_modify(client.config.organization, stage)
      end
    end
  end
end
