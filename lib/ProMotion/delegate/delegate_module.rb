module ProMotion
  module DelegateModule

    include ProMotion::Tabs
    include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2") # Only with iPad
    include ProMotion::DelegateNotifications

    attr_accessor :window, :aps_notification, :home_screen

    def application(application, willFinishLaunchingWithOptions:launch_options)
      will_load(application, launch_options) if respond_to?(:will_load)
    end

    def application(application, didFinishLaunchingWithOptions:launch_options)
      apply_status_bar
      on_load application, launch_options
      check_for_push_notification launch_options
      super rescue true # Can cause error message if no super is found, but it's harmless. Ignore.
    end

    def applicationDidBecomeActive(application)
      on_activate if respond_to?(:on_activate)
    end

    def applicationWillResignActive(application)
      will_deactivate if respond_to?(:will_deactivate)
    end

    def applicationDidEnterBackground(application)
      on_enter_background if respond_to?(:on_enter_background)
    end

    def applicationWillEnterForeground(application)
      will_enter_foreground if respond_to?(:will_enter_foreground)
    end

    def applicationWillTerminate(application)
      on_unload if respond_to?(:on_unload)
    end

    def application(application, openURL: url, sourceApplication:source_app, annotation: annotation)
      on_open_url({ url: url, source_app: source_app, annotation: annotation }) if respond_to?(:on_open_url)
    end

    def app_delegate
      self
    end

    def app_window
      self.window
    end

    def ui_window
      (defined?(Motion) && defined?(Motion::Xray) && defined?(Motion::Xray::XrayWindow)) ? Motion::Xray::XrayWindow : UIWindow
    end

    def open_screen(screen, args={})

      screen = screen.new if screen.respond_to?(:new)

      self.home_screen = screen

      self.window ||= self.ui_window.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = (screen.navigationController || screen)
      self.window.makeKeyAndVisible

      screen
    end
    alias :open :open_screen
    alias :open_root_screen :open_screen
    alias :home :open_screen

    def apply_status_bar
      self.class.send(:apply_status_bar)
    end

    def status_bar?
      UIApplication.sharedApplication.statusBarHidden
    end

    module ClassMethods

      def status_bar(visible = true, opts={})
        @status_bar_visible = visible
        @status_bar_opts = opts
      end

      def apply_status_bar
        @status_bar_visible ||= true
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

    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end
