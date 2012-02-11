lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'gearup/version'

Gem::Specification.new do |s|
  s.name            = "gearup"
  s.version         = Gearup::VERSION
  s.platform        = Gem::Platform::RUBY
  s.summary         = "a Rack-like interface for Gearman workers"

  s.description     = <<-DESC
Gearup provides a Rack-like interface for Gearman workers. Its aim is to
simplify the task of constructing focused, yet robust, workers, and to provide a
familiar and configurable binary to run them.
DESC

  s.files           = Dir['{bin/*,lib/**/*}'] + %w(README.md)
  s.bindir          = 'bin'
  s.executables     << 'gearup'
  s.require_path    = 'lib'
  s.extra_rdoc_files = ['README.md']
  s.test_files      = Dir['spec/**/*_spec.rb']

  s.author          = 'Brian Cobb'
  s.email           = 'b@bcobb.net'
  s.homepage        = 'http://bcobb.github.com/gearup'

  s.add_development_dependency 'rspec'
  s.add_dependency 'gearman-ruby'
end

