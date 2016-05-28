require_relative 'spec_helper'

# Mock external HTTP requests
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

# Pull in the code
require_relative '../lib/cyclid/client'
