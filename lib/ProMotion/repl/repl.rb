if RUBYMOTION_ENV == "development"
  module Kernel
    def pm_live_screens(opts={})
      if opts == false || opts.to_s.downcase == "off"
        @live_reload_timer.invalidate if @live_reload_timer
        @live_reload_timer = nil
        "Live reloading of PM screens is now off."
      else
        @live_reload_debug = opts[:debug]
        enable_pm_live_screens(opts[:interval] || 0.5)
      end
    end

    private

    def live_reload_timer_every(interval, &callback)
      NSTimer.scheduledTimerWithTimeInterval(interval, target: callback, selector: 'call:', userInfo: nil, repeats: true)
    end

    def enable_pm_live_screens(interval)
      # Get list of screen files
      return unless root_path = NSBundle.mainBundle.infoDictionary["ProjectRootPath"]

      path_query = "#{root_path}/app/screens/**/*.rb"
      puts path_query if @live_reload_debug
      screen_file_paths = Dir.glob(path_query)
      puts screen_file_paths if @live_reload_debug

      screens = screen_file_paths.inject({}) do |out, screen_path_file|
        out[screen_path_file] = Time.now
        out
      end

      @live_reload_timer = live_reload_timer_every(interval) do
        screen_changed = false
        screens.each do |screen, modified_date|
          if File.exist?(screen) && File.mtime(screen) > modified_date
            pm_reload_screen(screen)
            screens[screen] = File.mtime(screen)
          end
        end
      end

      "Live reloading of RMQ screens is now on."
    end

    def pm_reload_screen(screen)
      fresh_code = File.read(screen)
      eval(fresh_code)
      screen_names = pm_parse_screen_names(fresh_code)
      puts "Reloaded #{screen_names.join(", ")} #{screen}." if @live_reload_debug
      vcs = pm_all_view_controllers(UIApplication.sharedApplication.delegate.window.rootViewController)
      puts "Found #{vcs.map(&:to_s).join(", ")}." if @live_reload_debug
      vcs.each do |vc|
        if pm_is_in_ancestry?(vc, screen_names)
          puts "Sending :on_live_reload to #{vc.inspect}." if @live_reload_debug
          vc.send(:on_live_reload) if vc.respond_to?(:on_live_reload)
        end
      end
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

    def pm_parse_screen_names(code)
      code.split("\n").map do |code_line|
        matched = code_line.match(/^\s*class\s+(\S+)\s+</)
        matched[1] if matched
      end.compact
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
  end
end
