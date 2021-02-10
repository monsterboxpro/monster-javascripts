# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monster/javascripts/version'

Gem::Specification.new do |spec|
  spec.name          = "monster-javascripts"
  spec.version       = Monster::Javascripts::VERSION
  spec.authors       = ["Monsterbox Productions"]
  spec.email         = ["andrew@monsterboxpro.com"]
  spec.summary       = %q{Javascript files}
  spec.description   = %q{Javascripts files}
  spec.homepage      = "http://monsterboxpro.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 4.2.3"
  spec.add_dependency "version", "~> 1.0.0a"
end
