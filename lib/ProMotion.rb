unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

require "ProMotion/version"

Motion::Project::App.setup do |app|
  app.files = Dir.glob(File.join(File.dirname(__FILE__), 'ProMotion/**/*.rb')) | app.files
end