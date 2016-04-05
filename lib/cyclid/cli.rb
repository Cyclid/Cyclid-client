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
    end
  end
end
