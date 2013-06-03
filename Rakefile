$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'

# this follow from gemspec
Bundler.require(:development)

# this follow development code
require 'ProMotion'

Motion::Project::App.setup do |app|
  app.name = 'ProMotionTest'
  app.version = "0.99.0"
  app.redgreen_style = :focused # :focused, :full

  # Devices
  app.deployment_target = "6.0"
  app.device_family = [:ipad] # so we can test split screen capability

  app.detect_dependencies = true
end
