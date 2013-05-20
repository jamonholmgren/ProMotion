$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler/gem_tasks'
Bundler.setup
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'ProMotionTest'
  app.version = "0.99.0" # I've got 99 problems and the test app's version isn't one of them
  app.redgreen_style = :focused # :focused, :full

  # Devices
  app.deployment_target = "6.0"
  app.device_family = [:ipad] # so we can test split screen capability

  app.detect_dependencies = true
end

def all_files
  App.config.spec_files
end

def functional_files
  Dir.glob('./spec/functional/*.rb')
end

def unit_files
  Dir.glob('./spec/unit/*.rb')
end

namespace :spec do
  task :unit do
    App.config.spec_mode = true
    spec_files = all_files
    spec_files -= functional_files
    App.config.instance_variable_set("@spec_files", spec_files)
    Rake::Task["simulator"].invoke
  end

  task :functional do
    App.config.spec_mode = true
    spec_files = all_files
    spec_files -= unit_files
    App.config.instance_variable_set("@spec_files", spec_files)
    Rake::Task["simulator"].invoke
  end
end
