require 'base64'
require 'openssl'

require_rel 'admin/*.rb'

module Cyclid
  module Cli
    # 'admin' sub-command
    class Admin < Thor
      desc 'user', 'Manage users'
      subcommand 'user', AdminUser

      desc 'organization', 'Manage organizations'
      subcommand 'organization', AdminOrganization
      map 'org' => :organization
    end
  end
end
