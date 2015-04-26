# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ProMotion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "ProMotion"
  gem.authors       = ["Jamon Holmgren", "Mark Rickert", "Silas Matson"]
  gem.email         = ["jamon@clearsightstudio.com", "mark@mohawkapps.com", "silas@clearsightstudio.com"]
  gem.description   = "ProMotion is a fast way to get started building RubyMotion iOS apps."
  gem.summary       = "
                        ProMotion is a fast way to get started building RubyMotion apps. Instead of dealing
                        with UIViewControllers, UITableViewControllers, and the like, you work with Screens.
                        We abstract the view controller boilerplate to make iOS development more like Ruby
                        and less like Objective-C. With a memorable, concise syntax and a friendly, helpful
                        community, ProMotion is a great way to get started with iOS development.
                      "
  gem.homepage      = "https://github.com/clearsightstudio/ProMotion"
  gem.license       = "MIT"

  gem.files         = Dir.glob("lib/**/*.rb")
  gem.files         << "README.md"

  gem.executables   << "promotion"
  gem.test_files    = Dir.glob("spec/**/*.rb")
  gem.require_paths = ["lib"]
  gem.version       = ProMotion::VERSION

  gem.add_runtime_dependency("methadone", "~> 1.7")
  gem.add_runtime_dependency("motion_print", "~> 1.0")
  gem.add_development_dependency("webstub", "~> 1.1")
  gem.add_development_dependency("motion-stump", "~> 0.3")
  gem.add_development_dependency("motion-redgreen", "~> 0.1")
  gem.add_development_dependency("rake", ">= 10.0")
end
