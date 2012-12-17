module ProMotion
  class AppDelegateParent
    attr_accessor :window
    
    def application(application, didFinishLaunchingWithOptions:launch_options)
      return true if RUBYMOTION_ENV == "test"

      Console.log(" Your AppDelegate (usually in app_delegate.rb) needs an on_load(options) method.", withColor: Console::RED_COLOR) unless self.respond_to?("on_load:")

      on_load(application, launch_options)

      open_home_screen if has_home_screen

      true
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def app_window
      self.app_delegate.window
    end

    def load_root_screen(new_screen)
      self.window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = new_screen.main_controller
      self.window.makeKeyAndVisible
    end

    def open_screen(screen)
      home(screen)
    end
    alias :open :open_screen

    def home(screen)
      screen = screen.new if screen.respond_to?(:new)
      @home_screen = screen
    end

    def open_root_screen(new_screen)
      home(new_screen)
      open_home_screen
    end
    alias :fresh_start :open_root_screen

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
end