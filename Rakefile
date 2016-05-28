# encoding: utf-8

begin
  require 'bundler/setup'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

ENV['TEST_CONFIG'] = File.join(%w(config test))

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
