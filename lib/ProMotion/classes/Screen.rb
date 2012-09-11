module ProMotion
  # Instance methods
  class Screen
    include ProMotion::ScreenNavigation
    include ProMotion::ScreenElements
    
    attr_accessor :view_controller, :navigation_controller, :parent_screen, :first_screen, :tab_bar_item, :modal

    def initialize(args = {})
      args.each do |k, v|
        self.send "#{k}=", v if self.respond_to? "#{k}="
      end
      self.load_view_controller

      self.main_controller.hidesBottomBarWhenPushed = args[:hide_tab_bar] if args[:hide_tab_bar]
      self.view_controller.title = self.title
      self.add_nav_bar if args[:nav_bar]

      self.on_load if self.respond_to? :on_load
      self
    end

    def is_modal?
      self.modal == true
    end

    def has_nav_bar?
      self.navigation_controller.nil? != true
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
      right_button
    end

    def set_nav_bar_left_button(title, args={})
      args[:style]  ||= UIBarButtonItemStyleBordered
      args[:target] ||= self
      args[:action] ||= nil

      left_button = UIBarButtonItem.alloc.initWithTitle(title, style: args[:style], target: args[:target], action: args[:action])
      self.view_controller.navigationItem.leftBarButtonItem = left_button
      left_button
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
      self.will_appear if self.respond_to? :will_appear
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
    end
  end
end