# rubocop:disable Metrics/LineLength
Gem::Specification.new do |s|
  s.name        = 'cyclid-client'
  s.version     = '0.3.0'
  s.licenses    = ['Apache-2.0']
  s.summary     = 'Cyclid command line client & library'
  s.description = 'Cyclid command line client for interacting with a Cyclid server and the Ruby client library.'
  s.authors     = ['Kristian Van Der Vliet']
  s.email       = 'vanders@liqwyd.com'
  s.files       = Dir.glob('lib/**/*') + %w(LICENSE README.md)
  s.bindir      = 'bin'
  s.executables << 'cyclid'

  s.add_runtime_dependency('thor', '~> 0.19')
  s.add_runtime_dependency('require_all', '~> 1.3')
  s.add_runtime_dependency('oj', '~> 2.15')
  s.add_runtime_dependency('bcrypt', '~> 3.1')
  s.add_runtime_dependency('colorize', '~> 0.7')
  s.add_runtime_dependency('cyclid-core', '~> 0.1')
end
