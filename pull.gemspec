# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pull/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gabe Berke-Williams"]
  gem.email         = ["gabe@thoughtbot.com"]
  gem.description   = %q{Easily create Github pull requests from the command line.}
  gem.summary       = %q{Easily create Github pull requests from the command line.}
  gem.homepage      = "https://github.com/gabebw/pull"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "pull"
  gem.require_paths = ["lib"]
  gem.version       = Pull::VERSION

  gem.add_development_dependency("json")
end
