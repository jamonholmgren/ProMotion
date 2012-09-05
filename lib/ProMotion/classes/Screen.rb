module ProMotion
  module ScreenElements
    def add_view(view)
      return self.view_controller.view.addSubview(view)
    end

    def remove_view(view)
      view.removeFromSuperview
      view = nil
    end

    def add_view_to_subview(view, atTag:tag)
      subview = self.view_controller.view.viewWithTag(tag)
      return subview.addSubview(view)
    end

    def bounds
      return self.view_controller.view.bounds
    end

    def view
      return self.view_controller.view
    end

    def set_attributes(element, args = {})
      args.each do |k, v|
        element.send("#{k}=", v) if element.respond_to? "#{k}="
      end
      element
    end
  end

  module ScreenNavigation
    def open_screen(screen, args = {})
      # Instantiate screen if given a class instead
      screen = screen.new if screen.respond_to? :new
      screen.add_nav_bar if args[:nav_bar]
      screen.parent_screen = self

      screen.main_controller.hidesBottomBarWhenPushed = true if args[:hide_tab_bar]
      
      if args[:close_all]
        fresh_start(screen)
      elsif self.navigation_controller
        screen.navigation_controller = self.navigation_controller
        push_view_controller screen.view_controller
      else
        open_view_controller screen.main_controller
      end
      
      screen.on_opened if screen.respond_to? :on_opened
    end

    def fresh_start(screen)
      app_delegate.fresh_start(screen)
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
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
      tab_bar = tab_bar_controller(*screens)
      open_view_controller tab_bar
      screens.each do |s|
        s.on_opened if s.respond_to? :on_opened
        s.parent_screen = self if s.respond_to? "parent_screen="
      end
      tab_bar
    end

    def push_tab_bar(*screens)
      tab_bar = tab_bar_controller(*screens)
      push_view_controller tab_bar
      screens.each do |s|
        s.on_opened if s.respond_to? :on_opened
        s.parent_screen = self if s.respond_to? "parent_screen="
      end
      tab_bar
    end

    def open_view_controller(vc)
      UIApplication.sharedApplication.delegate.load_root_view vc
    end

    def push_view_controller(vc)
      # vc.hidesBottomBarWhenPushed = true if args[:hide_tab_bar]
      Console.log(" You need a nav_bar if you are going to push #{vc.to_s} onto it.", withColor: Console::RED_COLOR) unless self.navigation_controller
      self.navigation_controller.pushViewController(vc, animated: true)
    end
  end
end

module ProMotion
  # Instance methods
  class Screen
    include ProMotion::ScreenNavigation
    include ProMotion::ScreenElements
    
    attr_accessor :view_controller
    attr_accessor :navigation_controller
    attr_accessor :parent_screen
    attr_accessor :first_screen
    attr_accessor :tab_bar_item

    def initialize(attrs = {})
      attrs.each do |k, v|
        self.send "#{k}=", v if self.respond_to? "#{k}="
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

    def set_nav_bar_right_button(title, args={})
      args[:style]  ||= UIBarButtonItemStyleBordered
      args[:target] ||= self
      args[:action] ||= nil

      right_button = UIBarButtonItem.alloc.initWithTitle(title, style: args[:style], target: args[:target], action: args[:action])
      self.view_controller.navigationItem.rightBarButtonItem = right_button
    end

    def view_controller=(vc)
      vc = vc.alloc.initWithNibName(nil, bundle:nil) if vc.respond_to? :alloc
      if self.navigation_controller && self.first_screen?
        @view_controller = vc
        self.navigation_controller = NavigationController.alloc.initWithRootViewController(self.view_controller)
      else
        @view_controller = vc
      end
      @view_controller.screen = self if @view_controller.respond_to? "screen="

      refresh_tab_bar_item
    end

    def first_screen?
      self.first_screen == true
    end

    def set_view_controller(vc)
      self.view_controller = vc
    end

    def view_will_appear(animated)
    end

    def view_did_appear(animated)
      self.on_appear if self.respond_to? :on_appear
    end

    def title
      self.class.send :get_title
    end

    def title=(new_title)
      self.class.title = new_title
      self.view_controller.title = new_title
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
      def title=(t)
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