module ProMotion
  class AppDelegate
    attr_accessor :window
    
    def application(application, didFinishLaunchingWithOptions:launchOptions)
      @home_screen = self.class.get_home_screen
      
      if self.class.has_tab_bar
        # @root = NavigationController.alloc.initWithRootViewController(@home_screen.view_controller)
        # Set up tabbed bar here
      elsif self.class.has_nav_bar
        @root = NavigationController.alloc.initWithRootViewController(@home_screen.view_controller)
      else
        @root = @home_screen.view_controller
      end
      
      self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = @root
      self.window.makeKeyAndVisible
      
      true
    end
  end
  
  class AppDelegate
    class << self
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
      
      def tab_bar(screen)
        @tabbed = true
        screen = screen.new if screen.respond_to? :new
        @tabbed_screens ||= []
        @tabbed_screens << screen
      end
    end
  end
end