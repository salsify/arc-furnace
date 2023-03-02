# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arc-furnace/version'

Gem::Specification.new do |spec|
  spec.name          = 'arc-furnace'
  spec.version       = ArcFurnace::VERSION
  spec.authors       = ['Daniel Spangenberger', 'Brian Tenggren']
  spec.email         = ['dan@salsify.com']

  spec.summary       = 'Melds and transforms data from multiple sources into a single stream'
  spec.description   = 'An ETL library for Ruby that performs the basic actions of ETL: extract, transform, and load. Easily extensible.'
  spec.homepage      = 'http://github.com/salsify/arc-furnace'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '> 3.0.0'

  spec.add_dependency 'activesupport'
  spec.add_dependency 'axlsx'
  spec.add_dependency 'eigenclass'
  spec.add_dependency 'msgpack'
  spec.add_dependency 'roo', '~> 2.10.0'
  spec.add_dependency 'zip-zip'

  spec.add_development_dependency 'ice_nine'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
