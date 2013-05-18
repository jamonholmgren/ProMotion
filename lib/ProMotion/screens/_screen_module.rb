module ProMotion
  module ScreenModule
    include ProMotion::ScreenNavigation
    include ProMotion::ScreenElements
    include ProMotion::SystemHelper
    include ProMotion::ScreenTabs
    include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2")

    attr_accessor :parent_screen, :first_screen, :tab_bar_item, :tab_bar, :modal, :split_screen, :title

    def on_create(args = {})
      unless self.is_a?(UIViewController)
        raise StandardError.new("ERROR: Screens must extend UIViewController or a subclass of UIViewController.")
      end


      self.title = self.class.send(:get_title)

      args.each do |k, v|
        self.send("#{k}=", v) if self.respond_to?("#{k}=")
      end

      self.add_nav_bar if args[:nav_bar]
      self.on_init if self.respond_to?(:on_init)
      self.table_setup if self.respond_to?(:table_setup)
      self
    end

    def is_modal?
      self.modal == true
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
      self.navigation_controller ||= begin
        self.first_screen = true if self.respond_to?(:first_screen=)
        NavigationController.alloc.initWithRootViewController(self)
      end
    end

    def set_nav_bar_right_button(title, args={})
      args[:title] = title
      set_nav_bar_button :right, args
    end

    def set_nav_bar_left_button(title, args={})
      args[:title] = title
      set_nav_bar_button :left, args
    end

    # If you call set_nav_bar_button with a nil title and system_icon: UIBarButtonSystemItemAdd (or any other
    # system icon), the button is initialized with a barButtonSystemItem instead of a title.
    def set_nav_bar_button(side, args={})
      args[:style]  ||= UIBarButtonItemStyleBordered
      args[:target] ||= self
      args[:action] ||= nil

      button = case args[:title]
        when String
          UIBarButtonItem.alloc.initWithTitle(args[:title], style: args[:style], target: args[:target], action: args[:action])
        when UIImage
          UIBarButtonItem.alloc.initWithImage(args[:title], style: args[:style], target: args[:target], action: args[:action])
        when Symbol, NilClass
          UIBarButtonItem.alloc.initWithBarButtonSystemItem(args[:system_icon], target: args[:target], action: args[:action]) if args[:system_icon]
        when UIBarButtonItem
          args[:title]
        else
          PM.logger.error("Please supply a title string, a UIImage or :system.")
      end

      self.navigationItem.leftBarButtonItem = button if side == :left
      self.navigationItem.rightBarButtonItem = button if side == :right

      button
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
      self.will_appear
    end
    def will_appear; end

    def view_did_appear(animated)
      self.on_appear
    end
    def on_appear; end

    def view_will_disappear(animated)
      self.will_disappear
    end
    def will_disappear; end

    def view_did_disappear(animated)
      self.on_disappear
    end
    def on_disappear; end

    def main_controller
      self.navigation_controller || self
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
      orientations = 0
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].each do |ori|
        case ori
        when "UIInterfaceOrientationPortrait"
          orientations |= UIInterfaceOrientationMaskPortrait
        when "UIInterfaceOrientationLandscapeLeft"
          orientations |= UIInterfaceOrientationMaskLandscapeLeft
        when "UIInterfaceOrientationLandscapeRight"
          orientations |= UIInterfaceOrientationMaskLandscapeRight
        when "UIInterfaceOrientationPortraitUpsideDown"
          orientations |= UIInterfaceOrientationMaskPortraitUpsideDown
        end
      end
      orientations
    end

    def supported_device_families
      NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].map do |m|
        case m
        when "1"
          :iphone
        when "2"
          :ipad
        end
      end
    end

    def supported_device_family?(family)
      supported_device_families.include?(family)
    end

    # Class methods
    module ClassMethods
      def debug_mode
        @debug_mode
      end

      def debug_mode=(v)
        @debug_mode = v
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
