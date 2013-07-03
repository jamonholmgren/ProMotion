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
  app.redgreen_style = :full # :focused, :full
  app.frameworks += %w(CoreLocation MapKit)

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
  
  task :func do
    Rake::Task["spec:functional"].invoke
  end

  task :functional do
    App.config.spec_mode = true
    spec_files = all_files
    spec_files -= unit_files
    App.config.instance_variable_set("@spec_files", spec_files)
    Rake::Task["simulator"].invoke
  end

end

task :sim_close do
  sh "osascript -e 'tell application \"iphone simulator\" to quit'"
end
