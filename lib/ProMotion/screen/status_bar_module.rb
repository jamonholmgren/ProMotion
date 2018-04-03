module ProMotion
  module StatusBarModule
    def preferredStatusBarStyle
      styles = {
        light: UIStatusBarStyleLightContent,
        dark: UIStatusBarStyleDefault,
        default: UIStatusBarStyleDefault
      }
      styles[self.class.status_bar_style || app.delegate.status_bar_style]  || styles[:default]
    end

    def preferredStatusBarUpdateAnimation
      animations = {
        none: UIStatusBarAnimationNone,
        fade: UIStatusBarAnimationFade,
        slide: UIStatusBarAnimationSlide,
        default: UIStatusBarAnimationFade
      }
      animations[self.class.status_bar_animation || app.delegate.status_bar_animation] || animations[:default]
    end

    def prefersStatusBarHidden
      style = self.class.status_bar_style || app.delegate.status_bar_style
      [:none, :hidden].include?(style)
    end

    def hide_status_bar(opts = {})
      @previous_status_bar_style = self.class.status_bar_style
      self.class.status_bar_style(:hidden)
      update_status_bar_appearance(opts)
    end

    def show_status_bar(opts = {})
      new_style = case @previous_status_bar_style
                  when nil, :hidden, :none
                    opts[:style] || app.delegate.status_bar_style || :default
                  else
                    @previous_status_bar_style
                  end
      self.class.status_bar_style(new_style)
      update_status_bar_appearance(opts)
    end

    def update_status_bar_appearance(opts = {})
      if opts[:animated] == true
        UIView.animateWithDuration(0.3, animations: -> { setNeedsStatusBarAppearanceUpdate })
      else
        setNeedsStatusBarAppearanceUpdate
      end
    end

    module ClassMethods
      def status_bar(style = nil, args = {})
        info_plist_setting = NSBundle.mainBundle.objectForInfoDictionaryKey('UIViewControllerBasedStatusBarAppearance')
        if info_plist_setting == false
          mp "The default behavior of `status_bar` has changed. Calling `status_bar` will have no effect until you remove the 'UIViewControllerBasedStatusBarAppearance' setting from info_plist.", force_color: :yellow
        end
        @status_bar_style = style
        @status_bar_animation = args[:animation] if args[:animation]
      end

      def status_bar_style(val = nil)
        @status_bar_style = val if val
        @status_bar_style
      end

      def status_bar_animation(val = nil)
        @status_bar_animation = val if val
        @status_bar_animation
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
