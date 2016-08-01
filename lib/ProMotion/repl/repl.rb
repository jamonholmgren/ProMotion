if RUBYMOTION_ENV == "development"
  puts "Type `pm_live` to enable ProMotion's live reload system."
  module Kernel

    @live_reloaders ||= []

    def register_live_reloader watcher
      @live_reloaders << watcher
    end

    def pm_live(opts={})

      @watchers.each {|watcher| watcher.stop} if @watchers

      if opts == false || opts.to_s.downcase == "off"
        @watchers = nil
        "Live reloading of PM screens is now off."
      else
        @watchers = live_reloaders.collect {|reloader| reloader.(opts)}
        mp @watchers if opts[:debug]

        watching = @watchers.collect {|watcher| watcher.path_query}
        "Live reloading of #{watching.join(", ")} is now on."
      end
    end

    alias_method :pm_live_screens, :pm_live


    private

    def live_reloaders
      Kernel.instance_variable_get(:@live_reloaders)
    end

    def screen_watcher
      lambda do | opts |
        LiveReloader.new("app/screens/**/*.rb", opts).watch do |reloaded_file, new_code, class_names|
          vcs = pm_all_view_controllers(UIApplication.sharedApplication.delegate.window.rootViewController)
          vcs.each do |vc|
            if pm_is_in_ancestry?(vc, class_names)
              puts "Sending :on_live_reload to #{vc.inspect}." if opts[:debug]
              vc.send(:on_live_reload) if vc.respond_to?(:on_live_reload)
            end
          end
        end
      end
    end

    register_live_reloader screen_watcher

    def view_watcher
      lambda do | opts |
        LiveReloader.new("app/views/**/*.rb", opts).watch do |reloaded_file, new_code, class_names|
          views = pm_all_views(UIApplication.sharedApplication.delegate.window)
          views.each do |view|
            if pm_is_in_ancestry?(view, class_names)
              puts "Sending :on_live_reload to #{view.inspect}." if opts[:debug]
              view.send(:on_live_reload) if view.respond_to?(:on_live_reload)
            end
          end
        end
      end
    end

    register_live_reloader view_watcher

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
