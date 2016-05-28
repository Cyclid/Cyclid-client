require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'

  add_group 'Client', 'lib/cyclid/client'
  add_group 'Cli', 'lib/cyclid/cli'
end

# Configure RSpec
RSpec::Expectations.configuration.warn_about_potential_false_positives = false
