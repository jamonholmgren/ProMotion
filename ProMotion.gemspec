# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ProMotion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jamon Holmgren", "Mark Rickert", "Silas Matson"]
  gem.email         = ["jamon@clearsightstudio.com", "mark@mohawkapps.com", "silas@clearsightstudio.com"]
  gem.description   = "ProMotion is a fast way to easily build RubyMotion iOS apps."
  gem.summary       = "
                        ProMotion is a fast way to get started building RubyMotion apps. Instead of dealing
                        with UIViewControllers, UITableViewControllers, and the like, you work with Screens.
                        We abstract the view controller boilerplate to make iOS development more like Ruby 
                        and less like Objective-C. With a memorable, concise syntax and a friendly, helpful
                        community, ProMotion is the second most popular RubyMotion gem outside of BubbleWrap.
                      "
  gem.homepage      = "https://github.com/clearsightstudio/ProMotion"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   << "promotion"
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = "ProMotion"
  gem.require_paths = ["lib"]
  gem.version       = ProMotion::VERSION

  gem.add_dependency "motion-require", ">= 0.0.7"
  gem.add_development_dependency("webstub")
  gem.add_development_dependency("motion-stump")
  gem.add_development_dependency("motion-redgreen")
  gem.add_development_dependency("rake")
  gem.add_dependency("methadone")
end
