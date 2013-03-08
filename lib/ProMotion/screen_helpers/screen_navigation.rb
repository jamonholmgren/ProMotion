module ProMotion
  module ScreenNavigation
    # TODO: De-uglify this method.
    def open_screen(screen, args = {})
      # Instantiate screen if given a class
      screen = screen.new if screen.respond_to?(:new)

      screen.parent_screen = self if screen.respond_to?("parent_screen=")
      
      screen.title = args[:title] if args[:title] && screen.respond_to?("title=")

      screen.modal = args[:modal] if args[:modal] && screen.respond_to?("modal=")
      
      screen.hidesBottomBarWhenPushed = args[:hide_tab_bar] unless args[:hide_tab_bar].nil?

      screen.add_nav_bar if args[:nav_bar] && screen.respond_to?(:add_nav_bar)       

      unless args[:close_all] || args[:modal]
        screen.navigation_controller ||= self.navigation_controller if screen.respond_to?("navigation_controller=")
        screen.tab_bar ||= self.tab_bar if screen.respond_to?("tab_bar=")
      end

      screen.send(:on_load) if screen.respond_to?(:on_load)
      
      animated = args[:animated]
      animated ||= true

      if args[:close_all]
        open_root_screen(screen)
      elsif args[:modal]
        vc = screen
        vc = screen.main_controller if screen.respond_to?("main_controller=")
        if args[:nav_bar]
          self.presentModalViewController(vc.navigation_controller, animated:animated)
        else
          self.presentModalViewController(vc, animated:animated)
        end
      elsif args[:in_tab] && self.tab_bar
        vc = open_tab(args[:in_tab])
        if vc
          if vc.is_a?(UINavigationController)
            screen.navigation_controller = vc if screen.respond_to?("navigation_controller=")
            push_view_controller(screen, vc)
          else
            self.tab_bar.selectedIndex = vc.tabBarItem.tag
          end
        else
          Console.log("No tab bar item '#{args[:in_tab]}'", with_color: Console::RED_COLOR)
        end
      elsif self.navigation_controller
        push_view_controller screen
      elsif screen.respond_to?(:main_controller)
        open_view_controller screen.main_controller
      else
        open_view_controller screen
      end
    end
    alias :open :open_screen

    def open_root_screen(screen)
      app_delegate.open_root_screen(screen)
    end
    alias :fresh_start :open_root_screen

    def app_delegate
      UIApplication.sharedApplication.delegate
    end
    
    # TODO: De-uglify this method.
    def close_screen(args = {})
      args ||= {}
      args[:animated] = true
      
      # Pop current view, maybe with arguments, if in navigation controller
      previous_screen = self.parent_screen
      if self.is_modal?
        self.parent_screen.dismissModalViewControllerAnimated(args[:animated])
      elsif self.navigation_controller
        if args[:to_screen] && args[:to_screen].is_a?(UIViewController)
          self.navigation_controller.popToViewController(args[:to_screen], animated: args[:animated])
          previous_screen = args[:to_screen]
        else
          self.navigation_controller.popViewControllerAnimated(args[:animated])
        end
      else
        Console.log("Tried to close #{self.to_s}; however, this screen isn't modal or in a nav bar.", withColor: Console::PURPLE_COLOR)
      end
      
      if previous_screen && previous_screen.respond_to?(:on_return)
        if args
          previous_screen.send(:on_return, args)
        else
          previous_screen.send(:on_return)
        end
        ProMotion::Screen.current_screen = previous_screen
      end
    end
    alias :close :close_screen

    def open_view_controller(vc)
      UIApplication.sharedApplication.delegate.load_root_view vc
    end

    def push_view_controller(vc, nav_controller=nil)
      Console.log(" You need a nav_bar if you are going to push #{vc.to_s} onto it.", withColor: Console::RED_COLOR) unless self.navigation_controller
      nav_controller ||= self.navigation_controller
      nav_controller.pushViewController(vc, animated: true)
    end
  end
end
