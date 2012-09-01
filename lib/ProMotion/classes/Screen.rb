module ProMotion
  module ScreenNavigation
    def open_screen(screen, args = {})
      # Instantiate screen if given a class instead
      screen = screen.new if screen.respond_to? :new
      screen.add_nav_bar if args[:nav_bar]
      
      if args[:push]
        push_view_controller screen.main_controller
      else
        open_view_controller screen.main_controller
      end
      screen.parent_screen = self
      screen.on_opened if screen.respond_to? :on_opened
    end

    def push_screen(screen, args = {})
      args[:push] = true
      open_screen(screen, args)
    end

    def fresh_start(screen)
      UIApplication.sharedApplication.delegate.fresh_start(screen)
    end

    def close_screen(args = {})
      # Pop current view, maybe with arguments, if in navigation controller
      if self.navigation_controller
        self.navigation_controller.popViewControllerAnimated(true)
      else
        # What do we do now? Nothing to "pop"
      end
    end

    def tab_bar_controller(*screens)
      tab_bar_controller = UITabBarController.alloc.init

      view_controllers = []
      screens.each do |s|
        if s.is_a? Screen
          s = s.new if s.respond_to? :new
          view_controllers << s.main_controller
        else
          Console.log("Non-Screen passed into tab_bar_controller: #{s.to_s}", withColor: Console::RED_COLOR)
        end
      end

      tab_bar_controller.viewControllers = view_controllers
      tab_bar_controller
    end
    
    def open_tab_bar(*screens)
      open_view_controller tab_bar_controller(*screens)
      screens.each do |s|
        s.on_opened if s.respond_to? :on_opened
        s.parent_screen = self if s.respond_to? "parent_screen="
      end
    end

    def push_tab_bar(*screens)
      push_view_controller tab_bar_controller(*screens)
      screens.each do |s|
        s.on_opened if s.respond_to? :on_opened
        s.parent_screen = self if s.respond_to? "parent_screen="
      end
    end

    def open_view_controller(vc)
      UIApplication.sharedApplication.delegate.load_root_view vc
    end

    def push_view_controller(vc)
      Console.log(" You need a nav_bar if you are going to push #{vc.to_s} onto it.", withColor: Console::RED_COLOR) unless self.navigation_controller
      self.navigation_controller.pushViewController(vc, animated: true)
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
    attr_accessor :first_screen
    attr_accessor :tab_bar_item

    def initialize(attrs = {})
      attrs.each do |k, v|
        self.call "#{k}=", v if self.respond_to? "#{k}="
      end
      
      self.load_view_controller
      
      self.view_controller.title = self.title
      
      self.add_nav_bar if attrs[:nav_bar]

      self.on_load if self.respond_to? :on_load

      self
    end

    def load_view_controller
      self.view_controller ||= ViewController
    end

    def set_tab_bar_item(args = {})
      self.tab_bar_item = args
      refresh_tab_bar_item
    end

    def refresh_tab_bar_item
      self.main_controller.tabBarItem = ProMotion::TabBar.tab_bar_item(self.tab_bar_item) if self.tab_bar_item
    end
    
    def add_nav_bar
      unless self.navigation_controller
        self.navigation_controller = NavigationController.alloc.initWithRootViewController(self.view_controller)
        self.first_screen = true
      end
    end

    def view_controller=(vc)
      vc = vc.alloc.initWithNibName(nil, bundle:nil) if vc.respond_to? :alloc
      if self.navigation_controller && self.first_screen?
        @view_controller = vc
        self.navigation_controller = NavigationController.alloc.initWithRootViewController(self.view_controller)
      else
        @view_controller = vc
      end
      refresh_tab_bar_item
    end

    def first_screen?
      self.first_screen == true
    end

    def set_view_controller(vc)
      self.view_controller = vc
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