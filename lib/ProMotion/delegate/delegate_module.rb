module ProMotion
  module DelegateModule
    include ProMotion::Support
    include ProMotion::Tabs
    include ProMotion::SplitScreen if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad || (UIDevice.currentDevice.systemVersion.to_i >= 8 )

    attr_accessor :window, :home_screen

    def application(application, willFinishLaunchingWithOptions:launch_options)
      will_load(application, launch_options) if respond_to?(:will_load)
      true
    end

    def application(application, didFinishLaunchingWithOptions:launch_options)
      on_load application, launch_options
      # Requires 'ProMotion-push' gem.
      check_for_push_notification(launch_options) if respond_to?(:check_for_push_notification)
      super rescue true # Can cause error message if no super is found, but it's harmless. Ignore.
    end

    def applicationDidBecomeActive(application)
      try :on_activate
    end

    def applicationWillResignActive(application)
      try :will_deactivate
    end

    def applicationDidEnterBackground(application)
      try :on_enter_background
    end

    def applicationWillEnterForeground(application)
      try :will_enter_foreground
    end

    def applicationWillTerminate(application)
      try :on_unload
    end

    def application(application, openURL: url, sourceApplication:source_app, annotation: annotation)
      try :on_open_url, { url: url, source_app: source_app, annotation: annotation }
    end

    def application(application, continueUserActivity:user_activity, restorationHandler:restoration_handler)
      try :on_continue_user_activity, { user_activity: user_activity, restoration_handler: restoration_handler }
    end

    def ui_window
      (defined?(Motion) && defined?(Motion::Xray) && defined?(Motion::Xray::XrayWindow)) ? Motion::Xray::XrayWindow : UIWindow
    end

    def open(screen, args={})
      screen = set_up_screen_for_open(screen, args)

      self.home_screen = screen

      self.window ||= self.ui_window.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = (screen.navigationController || screen)
      self.window.tintColor = self.class.send(:get_tint_color) if self.window.respond_to?("tintColor=")
      self.window.makeKeyAndVisible

      screen
    end
    alias :open_screen :open
    alias :open_root_screen :open_screen

    def set_up_screen_for_open(screen, args={})
      # Instantiate screen if given a class
      screen = screen.new(args) if screen.respond_to?(:new)

      # Store screen options
      screen.screen_options.merge(args) if screen.respond_to?(:screen_options)

      # Set title & modal properties
      screen.title = args[:title] if args[:title] && screen.respond_to?(:title=)
      screen.modal = args[:modal] if args[:modal] && screen.respond_to?(:modal=)

      # Hide bottom bar?
      screen.hidesBottomBarWhenPushed = args[:hide_tab_bar] == true

      # Wrap in a PM::NavigationController?
      screen.add_nav_bar(args) if args[:nav_bar] && screen.respond_to?(:add_nav_bar)

      # Return modified screen instance
      screen
    end

    # DEPRECATED
    def status_bar?
      mp "The default behavior of `status_bar?` has changed. Calling `status_bar?` on AppDelegate may not return the correct result.", force_color: :yellow
      self.class.status_bar_style != :hidden
    end

    def status_bar_style
      self.class.status_bar_style
    end

    def status_bar_animation
      self.class.status_bar_animation
    end

  public

    module ClassMethods

      def status_bar(visible = true, opts = {})
        info_plist_setting = NSBundle.mainBundle.objectForInfoDictionaryKey('UIViewControllerBasedStatusBarAppearance')
        if info_plist_setting == false && visible == false
          mp "The default behavior of `status_bar` has changed. Calling `status_bar` will have no effect until you remove the 'UIViewControllerBasedStatusBarAppearance' setting from info_plist.", force_color: :yellow
        end
        @status_bar_style = case visible
                            when false then :hidden
                            when true  then :default
                            else visible
                            end
        @status_bar_animation = opts[:animation] || :default
      end

      def status_bar_style
        @status_bar_style
      end

      def status_bar_animation
        @status_bar_animation
      end

      def tint_color(c)
        @tint_color = c
      end

      def tint_color=(c)
        @tint_color = c
      end

      def get_tint_color
        @tint_color || nil
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
