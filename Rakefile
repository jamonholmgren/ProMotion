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
