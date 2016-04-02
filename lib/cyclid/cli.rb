require 'thor'
require 'require_all'

require_rel 'cli/*.rb'
require 'cyclid/client'

module Cyclid
  module Cli
    CYCLID_CONFIG_PATH = File.join(ENV['HOME'], '.cyclid', 'config')

    # Top level Thor-based CLI
    class Command < Thor
      class_option :config, aliases: '-c', type: :string, default: CYCLID_CONFIG_PATH

      desc 'user', 'Manage users'
      subcommand 'user', User
    end
  end
end
