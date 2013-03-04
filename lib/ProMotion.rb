unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

require "ProMotion/version"

Motion::Project::App.setup do |app|
  # app_delegate = Dir.glob(File.join(File.dirname(__FILE__), 'ProMotion/app_delegate.rb'))
  # app.files = Dir.glob(File.join(File.dirname(__FILE__), 'ProMotion/**/*.rb')) | app_delegate | app.files

  original_files = app.files
  app.files = FileList[File.join(File.dirname(__FILE__), 'ProMotion/**/*.rb')].exclude(File.join(File.dirname(__FILE__), 'ProMotion/app_delegate.rb'))
  app.files = app.files | Dir.glob(File.join(File.dirname(__FILE__), 'ProMotion/app_delegate.rb')) | original_files
end