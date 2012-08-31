module ProMotion
  class AppDelegateParent
    attr_accessor :window
    
    def application(application, didFinishLaunchingWithOptions:launchOptions)
      return true if RUBYMOTION_ENV == "test"

      Console.log("Your AppDelegate (usually in app_delegate.rb) needs an on_app_load(options) method.", withColor: Console::RED_COLOR) unless self.respond_to? :on_app_load
      on_app_load launchOptions

      Console.log("You need to specify a home screen with home, nav_bar, or tab_bar.", withColor: Console::RED_COLOR) unless has_home_screen
      if has_tab_bar
        # @root = NavigationController.alloc.initWithRootViewController(@home_screen.view_controller)
        # Set up tabbed bar here
      elsif has_nav_bar
        @root = NavigationController.alloc.initWithRootViewController(@home_screen.view_controller)
      else
        @root = @home_screen.view_controller
      end
      
      self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = @root
      self.window.makeKeyAndVisible
      
      true
    end

    def home(screen)
      screen = screen.new if screen.respond_to? :new
      @home_screen = screen
    end
    
    def nav_bar(screen)
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

    def tab_bar(screen, args = {})
      @tabbed = true
      screen = screen.new if screen.respond_to? :new
      @tabbed_screens ||= []
      @tabbed_screens << screen
      @home_screen = screen if !screen || args[:default]
    end

    def has_tab_bar
      @tabbed
    end
  end
end