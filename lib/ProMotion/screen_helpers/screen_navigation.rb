module ProMotion
  module ScreenNavigation

    def open_screen(screen, args = {})

      # Apply properties to instance
      screen = setup_screen_for_open(screen, args)
      ensure_wrapper_controller_in_place(screen, args)

      screen.send(:on_load) if screen.respond_to?(:on_load)
      animated = args[:animated] || true

      if args[:in_detail] && self.split_screen
        self.split_screen.detail_screen = screen

      elsif args[:in_master] && self.split_screen
        self.split_screen.master_screen = screen 

      elsif args[:close_all]
        open_root_screen screen

      elsif args[:modal]
        present_modal_view_controller screen, animated

      elsif args[:in_tab] && self.tab_bar
        present_view_controller_in_tab_bar_controller screen, args[:in_tab]

      elsif self.navigation_controller
        push_view_controller screen

      else
        open_root_screen screen.pm_main_controller

      end

    end
    alias :open :open_screen

    def open_root_screen(screen)
      app_delegate.open_root_screen(screen)
    end

    def open_modal(screen, args = {})
      open screen, args.merge({ modal: true })
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def close_screen(args = {})
      args ||= {}
      args = { sender: args } unless args.is_a?(Hash)
      args[:animated] ||= true

      if self.modal?
        close_modal_screen args

      elsif self.navigation_controller
        close_nav_screen args
        send_on_return(args) # TODO: this would be better implemented in a callback or view_did_disappear.

      else
        PM.logger.warn "Tried to close #{self.to_s}; however, this screen isn't modal or in a nav bar."

      end
    end
    alias :close :close_screen

    def send_on_return(args = {})
      if self.parent_screen && self.parent_screen.respond_to?(:on_return)
        if args
          self.parent_screen.send(:on_return, args)
        else
          self.parent_screen.send(:on_return)
        end
      end
    end

    def open_view_controller(screen)
      PM.logger.deprecated "Use `open_root_screen` instead of the more ambiguous `open_view_controller`."
      open_root_screen screen
    end

    def push_view_controller(vc, nav_controller=nil)
      unless self.navigation_controller
        PM.logger.error "You need a nav_bar if you are going to push #{vc.to_s} onto it."
      end
      nav_controller ||= self.navigation_controller
      vc.first_screen = false if vc.respond_to?(:first_screen=)
      nav_controller.pushViewController(vc, animated: true)
    end

    protected

    def setup_screen_for_open(screen, args={})

      # Instantiate screen if given a class
      screen = screen.new if screen.respond_to?(:new)

      # Set parent, title & modal properties
      screen.parent_screen = self if screen.respond_to?("parent_screen=")
      screen.title = args[:title] if args[:title] && screen.respond_to?("title=")
      screen.modal = args[:modal] if args[:modal] && screen.respond_to?("modal=")

      # Hide bottom bar?
      screen.hidesBottomBarWhenPushed = args[:hide_tab_bar] == true

      # Wrap in a PM::NavigationController?
      screen.add_nav_bar if args[:nav_bar] && screen.respond_to?(:add_nav_bar)

      # Return modified screen instance
      screen

    end

    def ensure_wrapper_controller_in_place(screen, args={})
      unless args[:close_all] || args[:modal]
        screen.navigation_controller ||= self.navigation_controller if screen.respond_to?("navigation_controller=")
        screen.tab_bar ||= self.tab_bar if screen.respond_to?("tab_bar=")
      end
    end

    def present_modal_view_controller(screen, animated)
      self.presentModalViewController(screen.pm_main_controller, animated:animated)
    end

    def present_view_controller_in_tab_bar_controller(screen, tab_name)
      vc = open_tab tab_name
      if vc

        if vc.is_a?(UINavigationController)
          screen.navigation_controller = vc if screen.respond_to?("navigation_controller=")
          push_view_controller(screen, vc)
        else
          # TODO: This should probably open the vc, shouldn't it?
          # This isn't well tested and needs to work better.
          self.tab_bar.selectedIndex = vc.tabBarItem.tag
        end

      else
        PM.logger.error "No tab bar item '#{tab_name}'"
      end
    end

    def close_modal_screen(args={})
      args[:animated] ||= true
      self.parent_screen.dismissViewControllerAnimated(args[:animated], completion: lambda {
        send_on_return(args)
      })
    end

    def close_nav_screen(args={})
      args[:animated] ||= true
      if args[:to_screen] && args[:to_screen].is_a?(UIViewController)
        self.parent_screen = args[:to_screen]
        self.navigation_controller.popToViewController(args[:to_screen], animated: args[:animated])
      else
        self.navigation_controller.popViewControllerAnimated(args[:animated])
      end
    end

  end
end
