# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pararest/version'

Gem::Specification.new do |spec|
  spec.name          = 'pararest'
  spec.version       = Pararest::VERSION
  spec.authors       = ['Shingo Noguchi']
  spec.email         = ['noguchi@daifukuya.com']
  spec.description   = 'Paralell REST Web API Client'
  spec.summary       = 'Supports Y!J Auctions/Shopping, Rakuten'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.1.0'
  spec.add_development_dependency 'rake'
  spec.add_dependency 'faraday'
  spec.add_dependency 'mime-types'
  spec.add_dependency 'typhoeus'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'multi_xml'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'hashie'
end
