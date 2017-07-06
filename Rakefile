# encoding: utf-8
# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

begin
  require 'bundler/setup'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

ENV['TEST_CONFIG'] = File.join(%w[config test])

require 'rubygems/tasks'
Gem::Tasks.new

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    abort 'Rubocop is not available.'
  end
end

begin
  require 'yard'
rescue LoadError
  task :yard do
    abort 'YARD is not available.'
  end
end

task :doc do
  YARD::CLI::Yardoc.run('--list-undoc', '--output-dir', 'doc/client', 'lib/cyclid/client.rb', 'lib/cyclid/config.rb', 'lib/cyclid/client/*.rb')
end
