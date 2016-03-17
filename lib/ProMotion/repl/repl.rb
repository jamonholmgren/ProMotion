if RUBYMOTION_ENV == "development"
  puts "Type `pm_live` to enable ProMotion's live reload system."
  module Kernel
    def pm_live(opts={})
      @screen_watcher.stop if @screen_watcher
      @view_watcher.stop if @view_watcher
      @layout_watcher.stop if @layout_watcher

      if opts == false || opts.to_s.downcase == "off"
        "Live reloading of PM screens is now off."
      else
        @screen_watcher = LiveReloader.new("app/screens/**/*.rb", opts).watch do |reloaded_file, new_code, class_names|
          vcs = pm_all_view_controllers(UIApplication.sharedApplication.delegate.window.rootViewController)
          vcs.each do |vc|
            if pm_is_in_ancestry?(vc, class_names)
              puts "Sending :on_live_reload to #{vc.inspect}." if opts[:debug]
              vc.send(:on_live_reload) if vc.respond_to?(:on_live_reload)
            end
          end
        end

        @view_watcher = LiveReloader.new("app/views/**/*.rb", opts).watch do |reloaded_file, new_code, class_names|
          views = pm_all_views(UIApplication.sharedApplication.delegate.window)
          views.each do |view|
            if pm_is_in_ancestry?(view, class_names)
              puts "Sending :on_live_reload to #{view.inspect}." if opts[:debug]
              view.send(:on_live_reload) if view.respond_to?(:on_live_reload)
            end
          end
        end

        @layout_watcher = LiveReloader.new("app/layouts/**/*.rb", opts).watch do |reloaded_file, new_code, class_names|
          vcs = pm_all_view_controllers(UIApplication.sharedApplication.delegate.window.rootViewController)
          vcs.each do |vc|
            if pm_is_layout?(vc, class_names) 
              puts "Sending :on_live_reload to #{vc.inspect}." #if opts[:debug]
              vc.send(:on_live_reload) if vc.respond_to?(:on_live_reload)
            end
          end
        end

        "Live reloading of screens, views, and layouts is now on."
      end
    end
    alias_method :pm_live_screens, :pm_live


    private

    def pm_is_layout?(vc, layout_code)
      definition = layout_code.detect {|e| e =~ /class\s*(\S*)Layout/}
      screen_name = "#{$1}Screen"
      vc.class.to_s == screen_name
    end

    # Very permissive. Might get unnecessary reloads. That's okay.
    def pm_is_in_ancestry?(vc, screen_names)
      screen_names.any? do |screen_name|
        vc.class.to_s.include?(screen_name) ||
        vc.class.ancestors.any? do |ancestor|
          screen_name.include?(ancestor.to_s)
        end
      end
    end

    def pm_all_view_controllers(root_view_controller)
      vcs = [ root_view_controller ]
      if root_view_controller.respond_to?(:viewControllers)
        vcs = vcs + root_view_controller.viewControllers.map{|vc| pm_all_view_controllers(vc) }
      end
      if root_view_controller.respond_to?(:childViewControllers)
        vcs = vcs + root_view_controller.childViewControllers.map{|vc| pm_all_view_controllers(vc) }
      end
      vcs.flatten.uniq
    end

    def pm_all_views(root_view)
      views = [ root_view ]
      views = views + views.map{|v| v.subviews.map{|sv| pm_all_views(sv) } }
      views.flatten.uniq
    end
  end
end
