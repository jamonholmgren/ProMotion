if RUBYMOTION_ENV == "development"
  module Kernel
    def pm_live_screens(opts={})
      @screen_timer.invalidate if @screen_timer
      @screen_timer = nil
      if opts == false || opts.to_s.downcase == "off"
        "Live reloading of PM screens is now off."
      else
        @screen_timer = pm_live_watch("#{pm_app_root_path}/app/screens/**/*.rb", opts) do |reloaded_file, new_code|
          screen_names = pm_parse_screen_names(new_code)
          puts "Reloaded #{screen_names.join(", ")} #{screen}." if opts[:debug]
          vcs = pm_all_view_controllers(UIApplication.sharedApplication.delegate.window.rootViewController)
          puts "Found #{vcs.map(&:to_s).join(", ")}." if opts[:debug]
          vcs.each do |vc|
            if pm_is_in_ancestry?(vc, screen_names)
              puts "Sending :on_live_reload to #{vc.inspect}." if opts[:debug]
              vc.send(:on_live_reload) if vc.respond_to?(:on_live_reload)
            end
          end
        end
        "Live reloading of PM screens is now on."
      end
    end

    def pm_live_watch(path_query, opts={}, &callback)
      # Get list of screen files
      puts path_query if opts[:debug]
      live_file_paths = Dir.glob(path_query)
      puts live_file_paths if opts[:debug]

      live_files = live_file_paths.inject({}) do |out, live_file_path_file|
        out[live_file_path_file] = Time.now
        out
      end

      live_reload_timer = pm_live_reload_timer_every(opts[:interval] || 0.5) do
        live_file_changed = false
        live_files.each do |live_file, modified_date|
          if File.exist?(live_file) && File.mtime(live_file) > modified_date
            new_code = File.read(live_file)
            eval(new_code)
            callback.call live_file, new_code
            live_files[live_file] = File.mtime(live_file)
          end
        end
      end

      "Watching #{path_query}."
      live_reload_timer
    end

    private

    def pm_live_reload_timer_every(interval, &callback)
      NSTimer.scheduledTimerWithTimeInterval(interval, target: callback, selector: 'call:', userInfo: nil, repeats: true)
    end

    def pm_app_root_path
      NSBundle.mainBundle.infoDictionary["ProjectRootPath"]
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
