module ProMotion
  module ScreenModule
    include ProMotion::ScreenNavigation
    include ProMotion::ScreenElements
    include ProMotion::SystemHelper

    attr_accessor :parent_screen, :first_screen, :tab_bar_item, :tab_bar, :modal

    def initialize(args = {})
      unless self.is_a?(UIViewController)
        raise StandardError.new("ERROR: Screens must extend UIViewController or a subclass of UIViewController.")
      end
      
      self.initWithNibName(nil, bundle:nil)

      args.each do |k, v|
        self.send("#{k}=", v) if self.respond_to?("#{k}=")
      end
      
      self.add_nav_bar if args[:nav_bar]
      self.on_init if self.respond_to?(:on_init)
      self
    end

    def is_modal?
      self.modal == true
    end

    def has_nav_bar?
      self.navigation_controller.nil? != true
    end

    def navigation_controller
      self.navigationController
    end

    def navigation_controller=(val)
      self.navigationController = val
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
      self.tabBarItem = ProMotion::TabBar.tab_bar_item(self.tab_bar_item) if self.tab_bar_item
    end

    def add_nav_bar
      self.navigationController = NavigationController.alloc.initWithRootViewController(self)
      self.first_screen = true
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
      ProMotion::Screen.current_screen = self
      self.will_appear
    end
    def will_appear; end

    def view_did_appear(animated)
      ProMotion::Screen.current_screen = self
      self.on_appear
    end
    def on_appear; end

    def view_will_disappear(animated)
      self.will_disappear
    end
    def will_disappear; end

    def view_did_disappear(animated)
      ProMotion::Screen.current_screen = self.parent_screen if self.parent_screen
      self.on_disappear
    end
    def on_disappear; end

    def title
      self.class.send(:get_title)
    end

    def title=(new_title)
      self.class.title = new_title
      self.view_controller.title = new_title if self.view_controller
    end

    def main_controller
      return self.navigationController if self.navigationController
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
      false
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

    def viewDidLoad
      super
      self.view_did_load if self.respond_to?(:view_did_load)
    end

    def viewWillAppear(animated)
      super
      self.view_will_appear(animated) if self.respond_to?(:view_will_appear)
    end

    def viewDidAppear(animated)
      super
      self.view_did_appear(animated) if self.respond_to?(:view_did_appear)
    end
    
    def viewWillDisappear(animated)
      if self.respond_to?(:view_will_disappear)
        self.view_will_disappear(animated)
      end
      super      
    end
    
    def viewDidDisappear(animated)
      if self.respond_to?(:view_did_disappear)
        self.view_did_disappear(animated)
      end
      super      
    end

    def shouldAutorotateToInterfaceOrientation(orientation)
      self.should_rotate(orientation)
    end

    def shouldAutorotate
      self.should_autorotate
    end

    def willRotateToInterfaceOrientation(orientation, duration:duration)
      self.will_rotate(orientation, duration)
    end
    
    def didRotateFromInterfaceOrientation(orientation)
      self.on_rotate
    end

    def dealloc
      $stderr.puts "Deallocating #{self.to_s}" if ProMotion::Screen.debug_mode
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