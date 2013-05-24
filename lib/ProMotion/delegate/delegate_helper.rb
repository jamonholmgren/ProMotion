module ProMotion
  module DelegateHelper
    
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
      
      self.window ||= self.ui_window.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = screen.pm_main_controller
      self.window.makeKeyAndVisible
      
    end
    alias :open :open_screen
    alias :open_root_screen :open_screen
    alias :home :open_screen
    
    module ClassMethods
    
      def status_bar(visible = true, opts={})
        UIApplication.sharedApplication.setStatusBarHidden(!visible, withAnimation:status_bar_animation(opts[:animation]))
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