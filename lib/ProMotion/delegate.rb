module ProMotion
  class Delegate
    include ProMotion::ScreenTabs
    include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2") # Only with iPad
    attr_accessor :window

    def application(application, didFinishLaunchingWithOptions:launch_options)
      unless self.respond_to?(:on_load)
        PM.logger.error "Your AppDelegate (usually in app_delegate.rb) needs an on_load(application, options) method."
      end

      on_load(application, launch_options)

      true
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def app_window
      self.app_delegate.window
    end

    def home(screen)
      screen = screen.new if screen.respond_to?(:new)
      @home_screen = screen
    end

    def load_root_screen(new_screen)
      new_screen = new_screen.main_controller if new_screen.respond_to?(:main_controller)

      self.window ||= self.ui_window.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = new_screen
      self.window.makeKeyAndVisible
    end
    
    def ui_window
      (defined?(Motion) && defined?(Motion::Xray) && defined?(Motion::Xray::XrayWindow)) ? Motion::Xray::XrayWindow : UIWindow
    end

    def open_screen(screen, args={})
      home(screen)
      open_home_screen
    end
    alias :open :open_screen
    alias :open_root_screen :open_screen

    def open_home_screen
      get_home_screen.send(:on_load) if get_home_screen.respond_to?(:on_load)
      load_root_screen get_home_screen
    end

    def get_home_screen
      @home_screen
    end

    def has_home_screen
      @home_screen.nil? == false
    end
  end
  class AppDelegateParent < Delegate; end # For backwards compatibility
end
