# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.setup
Bundler.require(:development)
require 'ProMotion'
require 'motion_print'

Motion::Project::App.setup do |app|
  app.name = 'ProMotion'
  app.device_family = [ :ipad ] # so we can test split screen capability
  app.detect_dependencies = false
  app.info_plist["UIViewControllerBasedStatusBarAppearance"] = false
  app.deployment_target = "8.0"

  # Adding file dependencies for tests
  # Not too many dependencies necessary
  app.files_dependencies({
    "app/screens/table_screen_refreshable.rb"   => [ "app/screens/test_table_screen.rb" ],
    "app/screens/table_screen_longpressable.rb" => [ "app/screens/test_table_screen.rb" ],
    "app/screens/test_collection_screen.rb" => [ "app/test_views/custom_collection_view_cell.rb" ],
    "app/screens/test_collection2_screen.rb" => [ "app/test_views/custom_collection_view_cell.rb" ],
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
