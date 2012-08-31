module ProMotion
  module ScreenNavigation
    def open_screen(screen, args = {})
      # Instantiate screen if given a class instead
      screen = screen.new if screen.respond_to? :new
      screen.add_nav_bar if args[:nav_bar]
      
      open_view_controller screen.main_controller
      screen.parent_screen = self
      screen.on_opened if screen.respond_to? :on_opened
    end

    def close_screen(args = {})
      # Pop current view, maybe with arguments, if in navigation controller
      if self.navigation_controller
        self.navigation_controller.popViewControllerAnimated(true)
      else
        # What do we do now? Nothing to "pop"
      end
    end

    def open_tab_bar(*screens)
      tab_bar_controller = UITabBarController.alloc.init

      view_controllers = []
      $stderr.puts screens.to_s
      screens.each do |s|
        if s.is_a? Screen
          s = s.new if s.respond_to? :new
          view_controllers << s.main_controller
        else
          Console.log("Non-Screen passed into open_tab_bar.", withColor: Console::RED_COLOR)
        end
      end

      tab_bar_controller.viewControllers = view_controllers

      open_view_controller tab_bar_controller

      screens.each do |s|
        s.on_opened if s.respond_to? :on_opened
        s.parent_screen = self if s.respond_to? "parent_screen="
      end
    end

    def open_view_controller(vc)
      # Push view onto existing UINavigationController, or make it visible if not in a UINavigationController.
      if self.navigation_controller
        self.navigation_controller.pushViewController(vc, animated: true)  
      else
        UIApplication.sharedApplication.delegate.load_root_view vc
      end
    end
  end
end

module ProMotion
  # Instance methods
  class Screen
    include ProMotion::ScreenNavigation

    attr_accessor :view_controller
    attr_accessor :navigation_controller
    attr_accessor :parent_screen

    def initialize(attrs = {})
      attrs.each do |k, v|
        self.call "#{k}=", v if self.respond_to? "#{k}="
      end
      
      unless attrs[:view_controller]
        self.view_controller = ViewController
        self.view_controller.title = self.title
      end

      self.add_nav_bar if attrs[:nav_bar]

      self.on_load if self.respond_to? :on_load
    end

    def set_tab_bar_item(args = {})
      self.main_controller.tabBarItem = ProMotion::TabBar.tab_bar_item(args)
    end
    
    def add_nav_bar
      self.navigation_controller ||= NavigationController.alloc.initWithRootViewController(self.view_controller)
    end

    def view_controller=(vc)
      vc = vc.alloc.initWithNibName(nil, bundle:nil) if vc.respond_to? :alloc
      @view_controller = vc
    end

    def set_view_controller(vc)
      view_controller = vc
    end

    def title
      self.class.send :get_title
    end

    def main_controller
      return self.navigation_controller if self.navigation_controller
      self.view_controller
    end
  end
  
  # Class methods
  class Screen
    class << self
      def title(t)
        @title = t
      end
      def get_title
        @title ||= self.to_s
      end
      def screen_type(type)
        @type = type
      end
      def get_screen_type
        @type ||= :normal
      end
    end
  end
end