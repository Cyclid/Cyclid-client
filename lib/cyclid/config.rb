require 'yaml'

module Cyclid
  module Client
    # Cyclid client per-organization configuration
    class Config
      attr_reader :path

      def initialize(path)
        @config = YAML.load_file(path)
      rescue StandardError => ex
        abort "Failed to load configuration file #{path}: #{ex}"
      end
    end
  end
end
