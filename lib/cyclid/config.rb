require 'yaml'

module Cyclid
  module Client
    # Cyclid client per-organization configuration
    class Config
      attr_reader :server, :port, :username, :secret, :path

      def initialize(path)
        @config = YAML.load_file(path)

        @server = @config['server']
        @port = @config['port'] || 80
        @username = @config['username']
        @secret = @config['secret']
      rescue StandardError => ex
        abort "Failed to load configuration file #{path}: #{ex}"
      end
    end
  end
end
