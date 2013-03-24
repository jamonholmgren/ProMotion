module ProMotion
  module ScreenTabs
    def tab_bar_controller(*screens)
      tab_bar_controller = UITabBarController.alloc.init

      view_controllers = []
      tag_index = 0

      screens.map! { |s| s.respond_to?(:new) ? s.new : s } # Initialize any classes

      screens.each do |s|
        if s.is_a?(ProMotion::Screen) || s.is_a?(ProMotion::TableScreen) || s.is_a?(ProMotion::ScreenModule) || s.is_a?(UISplitViewController)
          s = s.new if s.respond_to?(:new)
          s.tabBarItem.tag = tag_index
          s.parent_screen = self if self.is_a?(UIViewController) && s.respond_to?("parent_screen=")
          s.tab_bar = tab_bar_controller if s.respond_to?("tab_bar=")
          view_controllers << s.main_controller
          tag_index += 1
        else
          Console.log("Non-Screen passed into tab_bar_controller: #{s.to_s}", withColor: Console::RED_COLOR)
        end
        
        s.on_load if s.respond_to?(:on_load)
      end

      tab_bar_controller.viewControllers = view_controllers
      tab_bar_controller
    end
    
    # Open a UITabBarController with the specified screens as the
    # root view controller of the current app.
    # @param [Array] A comma-delimited list of screen classes or instances.
    # @return [UITabBarController]
    def open_tab_bar(*screens)
      tab_bar = tab_bar_controller(*screens)
      UIApplication.sharedApplication.delegate.load_root_screen(tab_bar)
      tab_bar
    end

    def split_screen(args)
      if !args[:screen1] or !args[:screen2]
        Console.log("split_screen needs exactly 2 screens.", withColor: Console::RED_COLOR)
        return
      end
      split = SplitViewController.alloc.init
      args[:screen1].split_screen=split
      args[:screen1].detail_split_screen=false
      args[:screen2].split_screen=split
      args[:screen2].detail_split_screen=true
      split.delegate=args[:screen2]
      split.tabBarItem=create_tab_bar_icon_custom(args[:title], args[:icon], 0)
      scr=[]
      [args[:screen1], args[:screen2]].each do |s|
        if s.navigation_controller
          scr<<s.navigation_controller
        else
          scr<<s
        end
      end
      split.viewControllers=scr
      split
    end

    def open_tab(tab)
      if tab.is_a? String
        return self.select(self.tab_bar, title: tab)
      elsif tab.is_a? Numeric
        tab_bar_controller.selectedIndex = tab
        return tab_bar_controller.viewControllers[tab]
      else
        $stderr.puts "Unable to open tab #{tab.to_s} because it isn't a string."
      end
    end

    def create_tab_bar_icon(icon, tag)
      return UITabBarItem.alloc.initWithTabBarSystemItem(icon, tag: tag)
    end

    def create_tab_bar_icon_custom(title, image_name, tag)
      icon_image = UIImage.imageNamed(image_name)
      return UITabBarItem.alloc.initWithTitle(title, image:icon_image, tag:tag)
    end

    def create_tab_bar_item(tab={})
      title = "Untitled"
      title = tab[:title] if tab[:title]
      tab[:tag] ||= @current_tag ||= 0
      @current_tag = tab[:tag] + 1
      
      tab_bar_item = create_tab_bar_icon(tab[:system_icon], tab[:tag]) if tab[:system_icon]
      tab_bar_item = create_tab_bar_icon_custom(title, tab[:icon], tab[:tag]) if tab[:icon]
      
      tab_bar_item.badgeValue = tab[:badge_number].to_s unless tab[:badge_number].nil? || tab[:badge_number] <= 0
      
      return tab_bar_item
    end

    def select(tab_bar_controller, title: title)
      root_controller = nil
      tab_bar_controller.viewControllers.each do |vc|
        if vc.tabBarItem.title == title
          tab_bar_controller.selectedViewController = vc
          root_controller = vc
          break
        end
      end
      root_controller
    end

    def replace_current_item(tab_bar_controller, view_controller: vc)
      controllers = NSMutableArray.arrayWithArray(tab_bar_controller.viewControllers)
      controllers.replaceObjectAtIndex(tab_bar_controller.selectedIndex, withObject: vc)
      tab_bar_controller.viewControllers = controllers
    end
  end
end
