$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler/gem_tasks'
Bundler.setup
Bundler.require
# require 'motion-table'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ProMotionTest'
  app.version = "0.3.0"


  # Devices
  app.deployment_target = "5.0"
  app.device_family = [:iphone, :ipad]

  app.detect_dependencies = true

  # Preload screens
  # app.files = Dir.glob(File.join(app.project_dir, 'lib/**/*.rb')) | app.files
end
