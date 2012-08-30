# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ProMotion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jamon Holmgren"]
  gem.email         = ["jamon@clearsightstudio.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ProMotion"
  gem.require_paths = ["lib"]
  gem.version       = ProMotion::VERSION
end
