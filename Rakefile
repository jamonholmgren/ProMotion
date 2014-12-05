# -*- coding: utf-8 -*-
RM_VERSION = "2.38" # Update .travis.yml too
unless File.exist?("/Library/RubyMotion#{RM_VERSION}/lib")
  abort "Couldn't find RubyMotion #{RM_VERSION}. Run `sudo motion update --cache-version=#{RM_VERSION}`."
end
$:.unshift("/Library/RubyMotion#{RM_VERSION}/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require(:development)
require 'ProMotion'

Motion::Project::App.setup do |app|
  app.name = 'ProMotion'
  app.device_family = [ :ipad ] # so we can test split screen capability
  app.detect_dependencies = false
  app.info_plist["UIViewControllerBasedStatusBarAppearance"] = false

  # Adding file dependencies for tests
  # Not too many dependencies necessary
  app.files_dependencies({
    "app/test_screens/table_screen_refreshable.rb"   => [ "app/test_screens/test_table_screen.rb" ],
    "app/test_screens/table_screen_longpressable.rb" => [ "app/test_screens/test_table_screen.rb" ],
  })
end

namespace :spec do
  task :unit do
    App.config.spec_mode = true
    spec_files = App.config.spec_files - Dir.glob('./spec/functional/**/*.rb')
    App.config.instance_variable_set("@spec_files", spec_files)
    Rake::Task["simulator"].invoke
  end
end
