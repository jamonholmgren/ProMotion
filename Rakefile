$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler/gem_tasks'
Bundler.setup
Bundler.require
# require 'motion-table'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ProMotionTest'
  app.version = "0.99.0" # I've got 99 problems and the test app's version isn't one of them
  app.redgreen_style = :focused # :focused, :full

  # Devices
  app.deployment_target = "5.0"
  app.device_family = [:ipad] # so we can test split screen capability

  app.detect_dependencies = true

  # Preload screens
  # app.files = Dir.glob(File.join(app.project_dir, 'lib/**/*.rb')) | app.files
end
