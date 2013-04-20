# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'realm/version'

Gem::Specification.new do |spec|
  spec.name          = "realm"
  spec.version       = Realm::VERSION
  spec.authors       = ["Ash Moran"]
  spec.email         = ["ash.moran@patchspace.co.uk"]
  spec.summary       = %q{Domain-Driven Design, CQRS and Event Sourcing}
  spec.description   = %q{Realm is a library to help apply DDD, CQRS and Event Sourcing to Ruby applications}
  spec.homepage      = "https://github.com/patchspace/realm"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
