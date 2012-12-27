module ProMotion
  module ScreenNavigation
    def open_screen(screen, args = {})
      # Instantiate screen if given a class
      screen = screen.new if screen.respond_to?(:new)

      if screen.is_a?(ProMotion::Screen || ProMotion::TableScreen)
        screen.parent_screen = self if screen.respond_to?("parent_screen=")
        screen.title = args[:title] if args[:title]

        screen.add_nav_bar if args[:nav_bar]
        
        unless args[:close_all] || args[:modal]
          screen.navigation_controller ||= self.navigation_controller
          screen.tab_bar ||= self.tab_bar
        end

        screen.modal = args[:modal] if args[:modal]
        
        screen.hidesBottomBarWhenPushed = args[:hide_tab_bar] if args[:hide_tab_bar]
        
        screen.send(:on_load) if screen.respond_to?(:on_load)
      end

      if args[:close_all]
        open_root_screen(screen)
      elsif args[:modal]
        vc = screen
        vc = screen.main_controller if screen.respond_to?(:main_controller)
        self.presentModalViewController(vc, animated:true)
      elsif args[:in_tab] && self.tab_bar
        vc = open_tab(args[:in_tab])
        if vc
          if vc.is_a?(UINavigationController)
            screen.navigation_controller = vc
            push_view_controller(screen, vc)
          else
            self.tab_bar.selectedIndex = vc.tabBarItem.tag
            $stderr.puts "#{self.tab_bar.selectedIndex} is selected and should be #{vc.tabBarItem.tag}"
            # PM::TabBar.replace_current_item(self.tab_bar, view_controller: screen.view_controller)
            # TODO: This doesn't work yet.
          end
        else
          $stderr.puts "No tab bar item '#{args[:in_tab]}'"
        end
      elsif self.navigation_controller
        push_view_controller screen
      else
        open_view_controller screen.main_controller
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

    def close_screen(args = {})
      args ||= {}
      args[:animated] = true
      
      # Pop current view, maybe with arguments, if in navigation controller
      previous_screen = self.parent_screen
      if self.is_modal?
        self.parent_screen.dismissModalViewControllerAnimated(args[:animated])
      elsif self.navigation_controller
        if args[:to_screen] && args[:to_screen].is_a?(Screen)
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