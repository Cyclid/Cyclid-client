# Cyclid top level module
module Cyclid
  module Cli
    # 'user' sub-command
    class User < Thor
      desc 'list', 'List all of the users'
      def list
        client = Cyclid::Client::Tilapia.new(options[:config])

        begin
          users = client.user_list
          users.each do |user|
            STDOUT.puts user
          end
        end
      end
    end
  end
end
