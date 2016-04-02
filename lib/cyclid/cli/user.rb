# Cyclid top level module
module Cyclid
  # 'user' sub-command
  class User < Thor
    desc 'list', 'List all of the users'
    def list
      %w(dave steve john).each do |user|
        STDOUT.puts user
      end
    end
  end
end
