module ProMotion
  class AppDelegateParent
    attr_accessor :window
    
    def application(application, didFinishLaunchingWithOptions:launchOptions)
      return true if RUBYMOTION_ENV == "test"

      Console.log("Your AppDelegate (usually in app_delegate.rb) needs an on_app_load(options) method.", withColor: Console::RED_COLOR) unless self.respond_to? :on_app_load
      on_app_load launchOptions

      Console.log("You need to specify a home screen with home, nav_bar, or tab_bar.", withColor: Console::RED_COLOR) unless has_home_screen
      if has_tab_bar
        # Set up tabbed bar here
      end
      
      @root = get_home_screen.main_controller
      
      load_root_view @root

      get_home_screen.on_opened if get_home_screen.respond_to? :on_opened
      
      true
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def app_window
      self.app_delegate.window
    end

    def load_root_view(new_view)
      self.window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = new_view
      self.window.makeKeyAndVisible
    end

    def home(screen)
      screen = screen.new if screen.respond_to? :new
      @home_screen = screen
    end
    
    def nav_bar(screen)
      screen = screen.new if screen.respond_to? :new
      screen.add_nav_bar
      @nav = true
      home(screen)
    end
    
    def has_nav_bar
      @nav
    end
    
    def get_home_screen
      @home_screen
    end

    def has_home_screen
      @home_screen.nil? == false
    end
  end
end