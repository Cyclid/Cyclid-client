require_relative 'spec_helper'

# Silence output from stdout & stderr
RSpec.configure do |c|
  c.before { allow($stdout).to receive(:puts) }
  c.before { allow($stdout).to receive(:write) }
  c.before { allow($stderr).to receive(:write) }
end

# Pull in the code
require_relative '../lib/cyclid/cli'
