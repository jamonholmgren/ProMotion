unless defined?(Motion::Project::Config)
  raise "The ProMotion gem must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  core_lib = File.join(File.dirname(__FILE__), 'ProMotion')
  insert_point = app.files.find_index { |file| file =~ /^(?:\.\/)?app\// } || 0

  # Dir.glob(File.join(core_lib, '**/*.rb')).reverse.each do |file|
  #   app.files.insert(insert_point, file)
  # end

  # app.files.unshift "#{core_lib}/pro_motion.rb"
  # app.files.unshift "#{core_lib}/styling/styling.rb"
  # app.files.unshift "#{core_lib}/table/cell/table_view_cell_module.rb"
  # app.files.unshift "#{core_lib}/delegate/delegate_parent.rb"
  # app.files.unshift "#{core_lib}/delegate/delegate_module.rb"
  # app.files.unshift "#{core_lib}/support/support.rb"
  # app.files.unshift "#{core_lib}/tabs/tabs.rb"
  # app.files.unshift "#{core_lib}/ipad/split_screen.rb"
  # app.files.unshift "#{core_lib}/screen/screen_module.rb"
  # app.files.unshift "#{core_lib}/screen/screen_navigation.rb"
  # app.files.unshift "#{core_lib}/table/table.rb"
  # app.files.unshift "#{core_lib}/table/table_utils.rb"
  # app.files.unshift "#{core_lib}/table/extensions/searchable.rb"
  # app.files.unshift "#{core_lib}/table/extensions/refreshable.rb"
  # app.files.unshift "#{core_lib}/table/extensions/indexable.rb"
  # app.files.unshift "#{core_lib}/table/extensions/longpressable.rb"
  # app.files.unshift "#{core_lib}/web/web_screen_module.rb"
  # app.files.flatten!.uniq!

  app.files = [
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/metaid.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/metareset.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/mock.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/mocks.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/proxy.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/stub.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/version.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/api.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/protocol.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/patch/session_configuration.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/json.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/registry.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/stub.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/spec_helpers.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/version.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/uri.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/version.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/navigation_controller.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/split_view_controller.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/ns_string.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/ns_url.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/styling/styling.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/cell/table_view_cell_module.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/table_view_cell.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/tab_bar_controller.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/tabs/tabs.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/table_view_controller.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/view_controller.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/support/support.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/ipad/split_screen.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/delegate/delegate_parent.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/delegate/delegate_module.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/delegate/delegate.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/screen/screen_navigation.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/screen/nav_bar_module.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/logger/logger.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/pro_motion.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/stubs/dummy_view.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/stubs/dummy_image_view.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/screen/screen_module.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/screen/screen.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/extensions/refreshable.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/extensions/indexable.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/extensions/searchable.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/extensions/longpressable.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/table_utils.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/grouped_table.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/data/table_data.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/table.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/web/web_screen_module.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/grouped_table_screen.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/table_screen.rb",
    "/Users/jh/Code/iOS/ProMotion/lib/ProMotion/web/web_screen.rb",
    "./app/test_screens/basic_screen.rb",
    "./app/test_screens/functional_screen.rb",
    "./app/test_screens/detail_screen.rb",
    "./app/test_screens/image_title_screen.rb",
    "./app/test_screens/image_view_title_screen.rb",
    "./app/test_screens/home_screen.rb",
    "./app/test_screens/navigation_controller.rb",
    "./app/test_screens/navigation_screen.rb",
    "./app/test_screens/test_table_screen.rb",
    "./app/test_screens/load_view_screen.rb",
    "./app/test_screens/master_screen.rb",
    "./app/test_screens/tab_screen.rb",
    "./app/test_screens/table_screen_indexable.rb",
    "./app/test_screens/present_screen.rb",
    "./app/test_screens/screen_module_view_controller.rb",
    "./app/test_screens/table_screen_searchable.rb",
    "./app/test_screens/test_delegate.rb",
    "./app/test_screens/table_screen_longpressable.rb",
    "./app/test_screens/table_screen_refreshable.rb",
    "./app/test_screens/test_web_screen.rb",
    "./app/test_screens/test_delegate_colors.rb",
    "./app/test_screens/test_mini_table_screen.rb",
    "./app/test_screens/view_title_screen.rb",
    "./app/test_views/custom_title_view.rb",
    "./app/test_screens/uiimage_title_screen.rb",
    "./app/test_screens/update_test_table_screen.rb",
    "./app/app_delegate.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-redgreen-0.1.0/lib/motion-redgreen/ansiterm.rb",
    "/Users/jh/.gem/ruby/2.2.0/gems/motion-redgreen-0.1.0/lib/motion-redgreen/string.rb",
  ]

  concat_path = File.join(File.dirname(__FILE__), "ProMotion-concat.rb")
  File.delete(concat_path) if File.exist?(concat_path)
  Motion::Project::App.info "Concat", concat_path
  File.open(concat_path, 'a') do |concat|
    app.files.each do |filename|
      concat << "# #{"=" * filename.length}\n"
      concat << "# #{filename}\n"
      concat << "# #{"=" * filename.length}\n"
      concat << File.read(filename)
      concat << "\n"
    end
  end

  app.files = [ concat_path ]
end
