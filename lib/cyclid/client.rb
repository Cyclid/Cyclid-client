require 'cyclid/config'

# XXX: Hax
require_rel '../../../Cyclid/lib/cyclid/hmac.rb'

module Cyclid
  module Client
    # In case you're wondering, this class required a name: it couldn't be
    # 'Cyclid' and it couldn't be 'Client'. Tilapia are a common type of
    # Cichlid...
    class Tilapia
      def initialize(config_path)
        @config = Config.new(config_path)
      end

      def user_list
        return %w(dave steve john)
      end
    end
  end
end
