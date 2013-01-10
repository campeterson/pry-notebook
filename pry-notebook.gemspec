# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pry-notebook/version'

Gem::Specification.new do |gem|
  gem.name          = "pry-notebook"
  gem.version       = Pry::Notebook::VERSION
  gem.authors       = ["Ryan Fitzgerald"]
  gem.email         = ["rwfitzge@gmail.com"]
  gem.description   = %q{Pry Notebook}
  gem.summary       = %q{A browser implementation of the Pry Ruby interactive shell - inspired by iPython Notebook}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "pry"
  gem.add_dependency "reel"

  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-minitest"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "rake"
end
