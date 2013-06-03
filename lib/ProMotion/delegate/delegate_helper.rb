module ProMotion
  module DelegateHelper

    attr_accessor :window, :aps_notification, :home_screen

    def application(application, didFinishLaunchingWithOptions:launch_options)
      
      apply_status_bar
      
      on_load application, launch_options

      check_for_push_notification launch_options
      
      # This will work when RubyMotion fixes a bug.
      # defined?(super) ? super : true

      # Workaround for now. Will display a NoMethodError, but ignore.
      super rescue true
    end
    
    def applicationWillTerminate(application)
      
      on_unload if respond_to?(:on_unload)
      
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
      screen.send(:on_load) if screen.respond_to?(:on_load)

      self.home_screen = screen

      self.window ||= self.ui_window.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = screen.pm_main_controller
      self.window.makeKeyAndVisible

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
          fade: UIStatusBarAnimationFade,
          slide: UIStatusBarAnimationSlide,
          none: UIStatusBarAnimationNone
        }[opt] || UIStatusBarAnimationNone
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end
