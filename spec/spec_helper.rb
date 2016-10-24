# frozen_string_literal: true
require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'

  # Note that the trailing slash is important, otherwise 'client' will also
  # match 'cli'
  add_group 'Client', 'lib/cyclid/client/'
  add_group 'Cli', 'lib/cyclid/cli/'
end

# Configure RSpec
RSpec::Expectations.configuration.warn_about_potential_false_positives = false

# Mock external HTTP requests
require 'webmock/rspec'

WebMock.disable_net_connect!
