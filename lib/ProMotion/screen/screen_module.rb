module ProMotion
  module ScreenModule
    include ProMotion::Support
    include ProMotion::ScreenNavigation
    include ProMotion::Styling
    include ProMotion::NavBarModule
    include ProMotion::Tabs
    include ProMotion::SplitScreen if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad

    attr_accessor :parent_screen, :first_screen, :modal, :split_screen

    def screen_init(args = {})
      check_ancestry
      resolve_title
      apply_properties(args)
      add_nav_bar(args) if args[:nav_bar]
      add_nav_bar_buttons
      tab_bar_setup
      try :screen_setup
      try :on_init
      PM.logger.deprecated "In #{self.class.to_s}, #on_create has been deprecated and removed. Use #screen_init instead." if respond_to?(:on_create)
    end

    def modal?
      self.modal == true
    end

    def resolve_title
      case self.class.title_type
      when :text then self.title = self.class.title
      when :view then self.navigationItem.titleView = self.class.title
      when :image then self.navigationItem.titleView = UIImageView.alloc.initWithImage(self.class.title)
      else
        PM.logger.warn("title expects string, UIView, or UIImage, but #{self.class.title.class.to_s} given.")
      end
    end

    def resolve_status_bar
      case self.class.status_bar_type
      when :none
        status_bar_hidden true
      when :light
        status_bar_hidden false
        status_bar_style UIStatusBarStyleLightContent
      else
        status_bar_hidden false
        status_bar_style UIStatusBarStyleDefault
      end
    end

    def add_nav_bar_buttons
      set_nav_bar_button(self.class.get_nav_bar_button[:side], self.class.get_nav_bar_button) if self.class.get_nav_bar_button
    end

    def status_bar_hidden(hidden)
      UIApplication.sharedApplication.setStatusBarHidden(hidden, withAnimation:self.class.status_bar_animation)
    end

    def status_bar_style(style)
      UIApplication.sharedApplication.setStatusBarStyle(style)
    end

    def parent_screen=(parent)
      @parent_screen = WeakRef.new(parent)
    end

    def first_screen?
      self.first_screen == true
    end

    def view_did_load
      self.send(:on_load) if self.respond_to?(:on_load)
    end

    def view_will_appear(animated)
      resolve_status_bar
      self.will_appear

      self.will_present if isMovingToParentViewController
    end
    def will_appear; end
    def will_present; end

    def view_did_appear(animated)
      self.on_appear

      self.on_present if isMovingToParentViewController
    end
    def on_appear; end
    def on_present; end

    def view_will_disappear(animated)
      self.will_disappear

      self.will_dismiss if isMovingFromParentViewController
    end
    def will_disappear; end
    def will_dismiss; end

    def view_did_disappear(animated)
      self.on_disappear

      self.on_dismiss if isMovingFromParentViewController
    end
    def on_disappear; end
    def on_dismiss; end

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

    def supported_orientation?(orientation)
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].include?(orientation)
    end

    def supported_device_families
      NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].map do |m|
        {
          "1" => :iphone,
          "2" => :ipad
        }[m] || :unknown_device
      end
    end

    def supported_device_family?(family)
      supported_device_families.include?(family)
    end

    def bounds
      return self.view_or_self.bounds
    end

    def frame
      return self.view_or_self.frame
    end

  private

    def apply_properties(args)
      reserved_args = [ :nav_bar, :hide_nav_bar, :hide_tab_bar, :animated, :close_all, :in_tab, :in_detail, :in_master, :to_screen ]
      set_attributes self, args.dup.delete_if { |k,v| reserved_args.include?(k) }
    end

    def tab_bar_setup
      self.tab_bar_item = self.class.send(:get_tab_bar_item)
      self.refresh_tab_bar_item if self.tab_bar_item
    end

    def check_ancestry
      unless self.is_a?(UIViewController)
        raise StandardError.new("ERROR: Screens must extend UIViewController or a subclass of UIViewController.")
      end
    end

    # Class methods
    module ClassMethods
      def title(t=nil)
        if t && t.is_a?(String) == false
          PM.logger.deprecated "You're trying to set the title of #{self.to_s} to an instance of #{t.class.to_s}. In ProMotion 2+, you must use `title_image` or `title_view` instead."
          return raise StandardError
        end
        @title = t if t
        @title_type = :text if t
        @title ||= self.to_s
      end

      def title_type
        @title_type || :text
      end

      def title_image(t)
        @title = t.is_a?(UIImage) ? t : UIImage.imageNamed(t)
        @title_type = :image
      end

      def title_view(t)
        @title = t
        @title_type = :view
      end

      def status_bar(style=nil, args={})
        if NSBundle.mainBundle.objectForInfoDictionaryKey('UIViewControllerBasedStatusBarAppearance').nil?
          PM.logger.warn("status_bar will have no effect unless you set 'UIViewControllerBasedStatusBarAppearance' to false in your info.plist")
        end
        @status_bar_style = style
        @status_bar_animation = args[:animation] if args[:animation]
      end

      def status_bar_type
        @status_bar_style || :default
      end

      def status_bar_animation
        @status_bar_animation || UIStatusBarAnimationSlide
      end

      def nav_bar_button(side, args={})
        @nav_bar_button_args = args
        @nav_bar_button_args[:side] = side
      end

      def get_nav_bar_button
        @nav_bar_button_args
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.extend(TabClassMethods) # TODO: Is there a better way?
    end
  end
end
