unless defined?(Motion::Project::Config)
  raise "The ProMotion gem must be required within a RubyMotion project Rakefile."
end

require 'motion_print'

Motion::Project::App.setup do |app|
  core_lib = File.join(File.dirname(__FILE__), 'ProMotion')
  insert_point = app.files.find_index { |file| file =~ /^(?:\.\/)?app\// } || 0

  Dir.glob(File.join(core_lib, '**/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end

  app.development do
    app.info_plist["ProjectRootPath"] ||= File.absolute_path(app.project_dir)
  end

  # For compatibility with libraries that don't use detect_dependencies. :-(
  app.files_dependencies({
    "#{core_lib}/version.rb" => [ "#{core_lib}/pro_motion.rb" ],
    "#{core_lib}/cocoatouch/table_view_cell.rb" => [ "#{core_lib}/table/cell/table_view_cell_module.rb" ],
    "#{core_lib}/table/cell/table_view_cell_module.rb" => [ "#{core_lib}/styling/styling.rb" ],
    "#{core_lib}/cocoatouch/collection_view_cell.rb" => [ "#{core_lib}/collection/cell/collection_view_cell_module.rb" ],
    "#{core_lib}/collection/collection_screen.rb" => [
       "#{core_lib}/screen/screen_module.rb",
       "#{core_lib}/collection/cell/collection_view_cell_module.rb",
    ],
    "#{core_lib}/collection/cell/collection_view_cell_module.rb" => [ "#{core_lib}/styling/styling.rb" ],
    "#{core_lib}/delegate/delegate.rb" => [ "#{core_lib}/delegate/delegate_parent.rb" ],
    "#{core_lib}/delegate/delegate_parent.rb" => [ "#{core_lib}/delegate/delegate_module.rb" ],
    "#{core_lib}/delegate/delegate_module.rb" => [
       "#{core_lib}/support/support.rb",
       "#{core_lib}/tabs/tabs.rb",
       "#{core_lib}/ipad/split_screen.rb"
    ],
    "#{core_lib}/screen/screen.rb" => [ "#{core_lib}/screen/screen_module.rb" ],
    "#{core_lib}/screen/screen_navigation.rb" => [ "#{core_lib}/support/support.rb", ],
    "#{core_lib}/screen/screen_module.rb" => [
       "#{core_lib}/tabs/tabs.rb",
       "#{core_lib}/screen/nav_bar_module.rb",
       "#{core_lib}/screen/screen_navigation.rb",
       "#{core_lib}/ipad/split_screen.rb",
    ],
    "#{core_lib}/table/data/table_data.rb" => [
       "#{core_lib}/table/data/table_data_builder.rb",
       "#{core_lib}/table/table.rb"
    ],
    "#{core_lib}/collection/data/collection_data.rb" => [
       "#{core_lib}/collection/data/collection_data_builder.rb",
       "#{core_lib}/collection/collection.rb",
       "#{core_lib}/table/table_utils.rb"
    ],
    "#{core_lib}/table/table.rb" => [
       "#{core_lib}/table/table_class_methods.rb",
       "#{core_lib}/table/table_builder.rb",
       "#{core_lib}/table/table_utils.rb",
       "#{core_lib}/table/extensions/searchable.rb",
       "#{core_lib}/table/extensions/refreshable.rb",
       "#{core_lib}/table/extensions/indexable.rb",
       "#{core_lib}/table/extensions/longpressable.rb"
    ],
    "#{core_lib}/collection/collection.rb" => [
       "#{core_lib}/collection/collection_class_methods.rb",
       "#{core_lib}/collection/collection_builder.rb",
       "#{core_lib}/table/table_utils.rb"
    ],
    "#{core_lib}/web/web_screen.rb" => [ "#{core_lib}/web/web_screen_module.rb" ],
    })
end
