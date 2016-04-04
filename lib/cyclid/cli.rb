require 'thor'
require 'require_all'

require_rel 'cli/*.rb'
require 'cyclid/client'

# Add some helpers to the Thor base class
class Thor
  private

  def debug?
    options[:debug] ? Logger::DEBUG : Logger::FATAL
  end
end

module Cyclid
  module Cli
    CYCLID_CONFIG_PATH = File.join(ENV['HOME'], '.cyclid', 'config')

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
    end
  end
end
