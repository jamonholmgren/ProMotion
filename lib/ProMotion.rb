unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

require "ProMotion/version"

Motion::Project::App.setup do |app|

  # Dir.glob(File.join(File.dirname(__FILE__), "ProMotion/**/*.rb")).each do |file|
  #   app.files.unshift(file)
  # end
  app.files = Dir.glob(File.join(File.dirname(__FILE__), 'ProMotion/**/*.rb')) | app.files
  # app.files = Dir.glob(File.join(File.dirname(__FILE__), 'ProMotion/helpers/**/*.rb')) | app.files
  # app.files = Dir.glob(File.join(File.dirname(__FILE__), 'ProMotion/modules/**/*.rb')) | app.files
  # app.files = Dir.glob(File.join(File.dirname(__FILE__), 'ProMotion/ext/**/*.rb')) | app.files
  
end