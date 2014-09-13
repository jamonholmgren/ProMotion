# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion2.32/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require(:development)
require 'ProMotion'

Motion::Project::App.setup do |app|
  app.name = 'ProMotion'
  app.device_family = [ :ipad ] # so we can test split screen capability
  app.detect_dependencies = true
end

namespace :spec do
  task :unit do
    App.config.spec_mode = true
    spec_files = App.config.spec_files - Dir.glob('./spec/functional/**/*.rb')
    App.config.instance_variable_set("@spec_files", spec_files)
    Rake::Task["simulator"].invoke
  end
end
