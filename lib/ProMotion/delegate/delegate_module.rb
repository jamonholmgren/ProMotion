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
      apply_status_bar
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
      screen = screen.new if screen.respond_to?(:new)

      self.home_screen = screen

      self.window ||= self.ui_window.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = (screen.navigationController || screen)
      self.window.tintColor = self.class.send(:get_tint_color) if self.window.respond_to?("tintColor=")
      self.window.makeKeyAndVisible

      screen
    end
    alias :open_screen :open
    alias :open_root_screen :open_screen

    def status_bar?
      UIApplication.sharedApplication.statusBarHidden
    end

  private

    def apply_status_bar
      self.class.send(:apply_status_bar)
    end

  public

    module ClassMethods

      def status_bar(visible = true, opts={})
        @status_bar_visible = visible
        @status_bar_opts = opts
      end

      def apply_status_bar
        @status_bar_visible = true if @status_bar_visible.nil?
        @status_bar_opts ||= { animation: :none }
        UIApplication.sharedApplication.setStatusBarHidden(!@status_bar_visible, withAnimation:status_bar_animation(@status_bar_opts[:animation]))
      end

      def status_bar_animation(opt)
        {
          fade:   UIStatusBarAnimationFade,
          slide:  UIStatusBarAnimationSlide,
          none:   UIStatusBarAnimationNone
        }[opt] || UIStatusBarAnimationNone
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
