# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "access-granted"
  spec.version       = "1.0.4"
  spec.authors       = ["Piotrek Okoński"]
  spec.email         = ["piotrek@okonski.org"]
  spec.description   = %q{Role based authorization gem}
  spec.summary       = %q{Elegant whitelist and role based authorization with ability to prioritize roles.}
  spec.homepage      = "https://github.com/chaps-io/access-granted"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
