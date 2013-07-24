# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ProMotion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jamon Holmgren", "Silas Matson", "ClearSight Studio"]
  gem.email         = ["jamon@clearsightstudio.com", "silas@clearsightstudio.com", "contact@clearsightstudio.com"]
  gem.description   = "ProMotion is a new way to easily build RubyMotion iOS apps."
  gem.summary       = "
                        ProMotion is a new way to organize RubyMotion apps. Instead of dealing
                        with UIViewControllers, you work with Screens. Screens are
                        a logical way to think of your app and include a ton of great
                        utilities to make iOS development more like Ruby and less like Objective-C.
                      "
  gem.homepage      = "https://github.com/clearsightstudio/ProMotion"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ProMotion"
  gem.require_paths = ["lib"]
  gem.version       = ProMotion::VERSION

  gem.add_development_dependency("webstub")
  gem.add_development_dependency("motion-stump")
  gem.add_development_dependency("motion-redgreen")
  gem.add_development_dependency("formotion")
  gem.add_development_dependency("rake")
end
