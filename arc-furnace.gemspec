# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arc-furnace/version'

Gem::Specification.new do |spec|
  spec.name          = "arc-furnace"
  spec.version       = ArcFurnace::VERSION
  spec.authors       = ["Daniel Spangenberger", "Brian Tenggren"]
  spec.email         = ["dan@salsify.com"]

  spec.summary       = %q{Melds and transforms data from multiple sources into a single stream}
  spec.description   = %q{An ETL library for Ruby that performs the basic actions of ETL: extract, transform, and load. Easily extensible.}
  spec.homepage      = "http://github.com/salsify/arc-furnace"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'msgpack', '~> 0.6'
  spec.add_dependency 'activesupport', '>= 3.2'
  spec.add_dependency 'eigenclass', '~> 2'
  spec.add_dependency 'roo', '>= 2.1'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'ice_nine', '>= 0.11'
end
