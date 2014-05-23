module ProMotion
  module ScreenModule
    # @require module:ScreenNavigation
    include ProMotion::ScreenNavigation
    # @require module:Styling
    include ProMotion::Styling
    # @require module:NavBarModule
    include ProMotion::NavBarModule
    # @require module:Tabs
    include ProMotion::Tabs
    # @require module:SplitScreen
    include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2")

    attr_accessor :parent_screen, :first_screen, :modal, :split_screen

    def screen_init(args = {})
      check_ancestry
      resolve_title
      tab_bar_setup
      set_attributes self, args
      add_nav_bar(args) if args[:nav_bar]
      screen_setup if self.respond_to?(:screen_setup)
      on_init if self.respond_to?(:on_init)
    end

    def modal?
      self.modal == true
    end

    def resolve_title
      case self.class.title_type
      when :text then self.title = self.class.title
      when :view then self.navigationItem.titleView = self.class.title
      when :image then self.navigationItem.titleView = UIImageView.alloc.initWithImage(UIImage.imageNamed(self.class.title))
      else
        PM.logger.warn("title expects string, UIView, or UIImage, but #{self.class.title.class.to_s} given.")
      end
    end

    def parent_screen=(parent)
      @parent_screen = WeakRef.new(parent)
    end

    def first_screen?
      self.first_screen == true
    end

    def view_did_load; end

    def view_will_appear(animated)
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
        @title = t if t
        @title_type = :text if t
        @title ||= self.to_s
      end

      def title_type
        @title_type || :text
      end

      def title_image(t)
        @title = t
        @title_type = :image
      end

      def title_view(t)
        @title = t
        @title_type = :view
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.extend(TabClassMethods) # TODO: Is there a better way?
    end
  end
end
