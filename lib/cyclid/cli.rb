require 'thor'
require 'require_all'

require_rel 'cli/*.rb'

module Cyclid
  # Top level Thor-based CLI
  class Client < Thor
    desc 'user', 'Manage users'
    subcommand 'user', User
  end
end
