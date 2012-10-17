module ProMotion
  module ScreenNavigation
    def open_screen(screen, args = {})
      # Instantiate screen if given a class instead
      screen = screen.new if screen.respond_to?(:new)

      screen.parent_screen = self
      screen.view_controller.title = args[:title] if args[:title]

      screen.add_nav_bar if args[:nav_bar]
      
      unless args[:close_all] || args[:modal]
        screen.navigation_controller ||= self.navigation_controller
        screen.tab_bar ||= self.tab_bar
      end

      screen.modal = args[:modal] if args[:modal]
      screen.send(:on_load) if screen.respond_to?(:on_load)
      screen.view_controller.hidesBottomBarWhenPushed = args[:hide_tab_bar] if args[:hide_tab_bar]

      if args[:close_all]
        fresh_start(screen)
      elsif args[:modal]
        self.view_controller.presentModalViewController(screen.main_controller, animated:true)
      elsif args[:in_tab] && self.tab_bar
        vc = open_tab(args[:in_tab])
        # $stderr.puts "Found a #{vc.to_s}"
        if vc
          if vc.is_a?(UINavigationController)
            push_view_controller(screen.view_controller, vc)
          else
            self.tab_bar.selectedIndex = vc.tabBarItem.tag
            $stderr.puts "#{self.tab_bar.selectedIndex} is selected and should be #{vc.tabBarItem.tag}"
            # PM::TabBar.replace_current_item(self.tab_bar, view_controller: screen.view_controller)
          end
        else
          $stderr.puts "No tab bar item '#{args[:in_tab]}'"
        end
      elsif self.navigation_controller
        push_view_controller screen.view_controller
      else
        open_view_controller screen.main_controller
      end

      if screen.respond_to?(:on_opened)
        screen.send(:on_opened)
      end
    end

    def fresh_start(screen)
      app_delegate.fresh_start(screen)
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def close_screen(args = {})
      args ||= {}
      
      # Pop current view, maybe with arguments, if in navigation controller
      previous_screen = self.parent_screen
      if self.is_modal?
        self.parent_screen.view_controller.dismissModalViewControllerAnimated(true)
      elsif self.navigation_controller
        if args[:to_screen]
          self.navigation_controller.popToViewController(args[:to_screen].view_controller, animated: true)
          previous_screen = args[:to_screen]
        else
          self.navigation_controller.popViewControllerAnimated(true)
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
      end
    end

    def tab_bar_controller(*screens)
      tab_bar_controller = UITabBarController.alloc.init

      view_controllers = []
      tag_index = 0
      screens.each do |s|
        if s.is_a? Screen
          s = s.new if s.respond_to?(:new)
          s.view_controller.tabBarItem.tag = tag_index
          view_controllers << s.main_controller
          tag_index += 1
        else
          Console.log("Non-Screen passed into tab_bar_controller: #{s.to_s}", withColor: Console::RED_COLOR)
        end
      end

      tab_bar_controller.viewControllers = view_controllers
      tab_bar_controller
    end
    
    # Open a UITabBarController with the specified screens as the
    # root view controller of the current app.
    # @param [Array] A comma-delimited list of screen classes or instances.
    # @return [UITabBarController] (this may change in the future; please
    #   do not rely on it right now)
    def open_tab_bar(*screens)
      tab_bar = tab_bar_controller(*screens)

      screens.each do |s|
        s.parent_screen = self if s.respond_to?("parent_screen=")
        s.tab_bar = tab_bar
        s.on_load if s.respond_to?(:on_load)
      end
      
      open_view_controller(tab_bar)

      screens.each do |s|
        s.on_opened if s.respond_to?(:on_opened)
      end

      tab_bar
    end

    def open_tab(tab)
      if tab.is_a? String
        return PM::TabBar.select(self.tab_bar, title: tab)
      else
        $stderr.puts "Unable to open tab #{tab.to_s} because it isn't a string."
      end
    end

    def open_view_controller(vc)
      UIApplication.sharedApplication.delegate.load_root_view vc
    end

    def push_view_controller(vc, nav_controller=nil)
      # vc.hidesBottomBarWhenPushed = true if args[:hide_tab_bar]
      Console.log(" You need a nav_bar if you are going to push #{vc.to_s} onto it.", withColor: Console::RED_COLOR) unless self.navigation_controller
      nav_controller ||= self.navigation_controller
      nav_controller.pushViewController(vc, animated: true)
    end
  end
end