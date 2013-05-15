unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

require "ProMotion/version"

Motion::Project::App.setup do |app|
  original_files = app.files
  delegate = File.join(File.dirname(__FILE__), 'ProMotion/delegate.rb')
  promotion_files = FileList[File.join(File.dirname(__FILE__), 'ProMotion/**/*.rb')].exclude(delegate).to_a
  app.files = (promotion_files << delegate) + original_files
end