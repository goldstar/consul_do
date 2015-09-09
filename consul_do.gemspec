# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'consul_do/version'

Gem::Specification.new do |spec|
  spec.name          = "consul_do"
  spec.version       = ConsulDo::VERSION
  spec.authors       = ["Jason Scholl"]
  spec.email         = ["jscholl@goldstar.com"]

  spec.summary       = %q{Consul key-based leader elections.}
  spec.description   = %q{Consul key-based leader elections and task coordination.}
  spec.homepage      = "https://github.com/goldstar/consul_do"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "vcr", "~> 2.9"
  spec.add_development_dependency "webmock", "~> 1.21"
  spec.add_development_dependency "simplecov", "~> 0.10"
end
