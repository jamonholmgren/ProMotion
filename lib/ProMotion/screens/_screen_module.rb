module ProMotion
  module ScreenModule
    include ProMotion::ScreenNavigation
    include ProMotion::ScreenElements
    include ProMotion::SystemHelper
    include ProMotion::ScreenTabs

    attr_accessor :parent_screen, :first_screen, :tab_bar_item, :tab_bar, :modal
    attr_accessor :split_screen, :detail_split_screen

    def on_create(args = {})
      unless self.is_a?(UIViewController)
        raise StandardError.new("ERROR: Screens must extend UIViewController or a subclass of UIViewController.")
      end
      
      args.each do |k, v|
        self.send("#{k}=", v) if self.respond_to?("#{k}=")
      end

      self.add_nav_bar if args[:nav_bar]
      self.table_setup if self.respond_to?(:table_setup)      
      self.on_init if self.respond_to?(:on_init)
      self
    end

    def is_modal?
      self.modal == true
    end

    def is_split_screen?
      self.split_screen.nil? != true
    end

    def splitViewController(svc, willHideViewController:vc, withBarButtonItem:bbi, forPopoverController:pc)
      bbi.title="Menu"
      self.split_screen.bbi=bbi
      self.navigationItem.setLeftBarButtonItem(bbi)
      self.split_screen.pc=pc
      self.popoverViewController = pc
    end

    def splitViewController(svc, willShowViewController:vc, invalidatingBarButtonItem:bbi)
      self.split_screen.bbi=nil
      self.split_screen.pc=nil
      self.navigationItem.setLeftBarButtonItems([], animated:false)
    end

    def has_nav_bar?
      self.navigation_controller.nil? != true
    end

    def navigation_controller
      @navigation_controller ||= self.navigationController
    end

    def navigation_controller=(val)
      @navigation_controller = val
      val
    end

    # [DEPRECATED]
    def load_view_controller
      warn "[DEPRECATION] `load_view_controller` is deprecated and doesn't actually do anything anymore. You can safely remove it from your code."
    end

    def set_tab_bar_item(args = {})
      self.tab_bar_item = args
      refresh_tab_bar_item
    end

    def refresh_tab_bar_item
      self.tabBarItem = create_tab_bar_item(self.tab_bar_item) if self.tab_bar_item
    end

    def add_nav_bar
      self.navigation_controller = NavigationController.alloc.initWithRootViewController(self)
      self.first_screen = true
    end

    def set_nav_bar_right_button(title, args={})
      args[:style]  ||= UIBarButtonItemStyleBordered
      args[:target] ||= self
      args[:action] ||= nil

      right_button = UIBarButtonItem.alloc.initWithTitle(title, style: args[:style], target: args[:target], action: args[:action])
      self.navigationItem.rightBarButtonItem = right_button
      right_button
    end

    def set_nav_bar_left_button(title, args={})
      args[:style]  ||= UIBarButtonItemStyleBordered
      args[:target] ||= self
      args[:action] ||= nil

      left_button = UIBarButtonItem.alloc.initWithTitle(title, style: args[:style], target: args[:target], action: args[:action])
      self.navigationItem.leftBarButtonItem = left_button
      left_button
    end

    # [DEPRECATED]
    def view_controller=(vc)
      set_view_controller(vc)
    end

    def first_screen?
      self.first_screen == true
    end

    # [DEPRECATED]
    def set_view_controller(vc)
      warn "[DEPRECATION] `set_view_controller` is deprecated and discontinued.  Please inherit from the UIViewController you wish to use and include ProMotion::ScreenViewController instead."
      self
    end

    def view_did_load; end
    def on_opened
      warn "[DEPRECATION] `on_opened` is deprecated.  Please use `on_appear` instead."
    end

    def view_will_appear(animated)
      # ProMotion::Screen.current_screen = self
      self.will_appear
    end
    def will_appear; end

    def view_did_appear(animated)
      # ProMotion::Screen.current_screen = self
      self.on_appear
    end
    def on_appear; end

    def view_will_disappear(animated)
      self.will_disappear
    end
    def will_disappear; end

    def view_did_disappear(animated)
      # ProMotion::Screen.current_screen = self.parent_screen if self.parent_screen
      self.on_disappear
    end
    def on_disappear; end

    def title
      self.class.send(:get_title)
    end

    def title=(new_title)
      self.class.title = new_title
      super
    end

    def main_controller
      return self.navigation_controller if self.navigation_controller
      self
    end

    def view_controller
      warn "[DEPRECATION] `view_controller` is deprecated, as screens are now UIViewController subclasses."
      self
    end

    def should_rotate(orientation)
      case orientation
      when UIInterfaceOrientationPortrait
        return supported_orientation?("UIInterfaceOrientationPortrait")
      when UIInterfaceOrientationLandscapeLeft
        return supported_orientation?("UIInterfaceOrientationLandscapeLeft")
      when UIInterfaceOrientationLandscapeRight
        return supported_orientation?("UIInterfaceOrientationLandscapeRight")
      when UIInterfaceOrientationPortraitUpsideDown
        return supported_orientation?("UIInterfaceOrientationPortraitUpsideDown")
      else
        false
      end
    end

    def will_rotate(orientation, duration)
    end

    def should_autorotate
      true
    end

    def on_rotate
    end

    def supported_orientation?(orientation)
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].include?(orientation)
    end

    def supported_orientations
      ors = 0
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].each do |ori|
        case ori
        when "UIInterfaceOrientationPortrait"
          ors |= UIInterfaceOrientationMaskPortrait
        when "UIInterfaceOrientationLandscapeLeft"
          ors |= UIInterfaceOrientationMaskLandscapeLeft
        when "UIInterfaceOrientationLandscapeRight"
          ors |= UIInterfaceOrientationMaskLandscapeRight
        when "UIInterfaceOrientationPortraitUpsideDown"
          ors |= UIInterfaceOrientationMaskPortraitUpsideDown
        end
      end
      ors
    end

    # Class methods
    module ClassMethods
      def debug_mode
        @debug_mode
      end

      def debug_mode=(v)
        @debug_mode = v
      end

      def current_screen=(s)
        @current_screen = s
      end

      def current_screen
        @current_screen
      end

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

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end