# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json/inflator/version'

Gem::Specification.new do |spec|
  spec.name          = "json-inflator"
  spec.version       = Json::Inflator::VERSION
  spec.authors       = ["Luis Canales"]
  spec.email         = ["kopz9999@gmail.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{This ruby gem actually contains the necessary logic to
    recycle a JSON object.}
  spec.description   = %q{This ruby gem actually contains the necessary logic to 
    recycle a JSON object. It expects a decycled JSON and returns one with circular
     references.}
  spec.homepage      = "https://github.com/kopz9999/json-inflator"
  spec.license       = "Apache License, v2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'jsonpath'
  spec.add_development_dependency 'oj'
  spec.add_development_dependency 'rspec'

end
