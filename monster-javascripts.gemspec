$:.push File.expand_path("../lib", __FILE__)

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

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 4.1.5"


  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
