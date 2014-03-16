# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ProMotion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jamon Holmgren", "Silas Matson", "Mark Rickert"]
  gem.email         = ["jamon@clearsightstudio.com", "silas@clearsightstudio.com", "mark@mohawkapps.com"]
  gem.summary       = "ProMotion makes it easy to build RubyMotion iOS screen-based apps."
  gem.description   = "
                        ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.
                        It introduces a clean, Ruby-style syntax for building screens that is easy to learn and remember and
                        abstracts a ton of boilerplate UIViewController, UINavigationController, and other iOS code into a
                        simple, Ruby-like DSL.
                      "
  gem.homepage      = "https://github.com/clearsightstudio/ProMotion"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   << "promotion"
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = "ProMotion"
  gem.require_paths = ["lib"]
  gem.version       = ProMotion::VERSION

  gem.add_dependency "motion-require", "~> 0.2"
  gem.add_runtime_dependency("methadone", "~> 1.3")
  gem.add_development_dependency("webstub", "~> 1.0")
  gem.add_development_dependency("motion-stump", "~> 0.3")
  gem.add_development_dependency("motion-redgreen", "~> 0.1")
  gem.add_development_dependency("rake", "~> 10.1")
end
