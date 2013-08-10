# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pararest/version'

Gem::Specification.new do |spec|
  spec.name          = "pararest"
  spec.version       = Pararest::VERSION
  spec.authors       = ["Shingo Noguchi"]
  spec.email         = ["noguchi@daifukuya.com"]
  spec.description   = %q{Paralell REST Web API Client}
  spec.summary       = %q{Supports Y!J Auctions/Shopping, Rakuten}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'faraday'
#  spec.add_development_dependency 'em-http-request'
  spec.add_development_dependency 'typhoeus'
  spec.add_development_dependency 'multi_json'
end
