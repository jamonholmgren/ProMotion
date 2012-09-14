module ProMotion
  class TabBar
    class << self
      # def tab_bar_item(args = {})
      #   title = "Untitled"
      #   title = args[:title] if args[:title]
      #   args[:tag] ||= 0

      #   tb_item = tab_bar_icon(args[:system_icon], args[:tag]) if args[:system_icon]
      #   tb_item = tab_bar_icon_custom(title, args[:icon], args[:tag]) if args[:icon]
        
      #   if tb_item
      #     tb_item.badgeValue = args[:badge_number].to_s unless args[:badge_number].nil? || tab[:badge_number] <= 0

      #     return tb_item
      #   end
      #   nil
      # end

      # def tab_bar_icon(icon, tag)
      #   return UITabBarItem.alloc.initWithTabBarSystemItem(icon, tag: tag)
      # end

      # def tab_bar_icon_custom(title, image_name, tag)
      #   icon_image = UIImage.imageNamed(image_name)
      #   return UITabBarItem.alloc.initWithTitle(title, image:icon_image, tag:tag)
      # end




      def createTabBarControllerFromData(data)
        data = self.setTags(data)

        tabBarController = UITabBarController.alloc.init
        tabBarController.viewControllers = self.tabControllersFromData(data)

        return tabBarController
      end

      def setTags(data)
        tagNumber = 0
        
        data.each do |d|
          d[:tag] = tagNumber
          tagNumber += 1
        end

        return data
      end

      def tabBarIcon(icon, tag)
        return UITabBarItem.alloc.initWithTabBarSystemItem(icon, tag: tag)
      end

      def tabBarIconCustom(title, imageName, tag)
        iconImage = UIImage.imageNamed(imageName)
        return UITabBarItem.alloc.initWithTitle(title, image:iconImage, tag:tag)
      end

      def tabControllersFromData(data)
        mt_tab_controllers = []

        data.each do |tab|
          mt_tab_controllers << self.controllerFromTabData(tab)
        end

        return mt_tab_controllers
      end

      def controllerFromTabData(tab)
        tab[:badgeNumber] = 0 unless tab[:badgeNumber]
        tab[:tag] = 0 unless tab[:tag]
        
        viewController = tab[:viewController]
        viewController = tab[:viewController].alloc.init if tab[:viewController].respond_to?(:alloc)
        
        if tab[:navigationController]
          controller = UINavigationController.alloc.initWithRootViewController(viewController)
        else
          controller = viewController
        end

        controller.tabBarItem = self.tabBarItem(tab)
        controller.tabBarItem.title = controller.title unless tab[:title]

        return controller
      end

      def tabBarItem(tab)
        title = "Untitled"
        title = tab[:title] if tab[:title]

        tabBarItem = tabBarIcon(tab[:systemIcon], tab[:tag]) if tab[:systemIcon]
        tabBarItem = tabBarIconCustom(title, tab[:icon], tab[:tag]) if tab[:icon]
        
        tabBarItem.badgeValue = tab[:badgeNumber].to_s unless tab[:badgeNumber].nil? || tab[:badgeNumber] <= 0
        
        return tabBarItem
      end

      def select(tabBarController, title: title)
        root_controller = nil
        tabBarController.viewControllers.each do |vc|
          if vc.tabBarItem.title == title
            tabBarController.selectedIndex = vc.tabBarItem.tag
            root_controller = vc
            break
          end
        end
        root_controller
      end

      def select(tabBarController, tag: tag)
        tabBarController.selectedIndex = tag
      end

      def replace_current_item(tabBarController, view_controller: vc)
        controllers = NSMutableArray.arrayWithArray(tabBarController.viewControllers)
        controllers.replaceObjectAtIndex(tabBarController.selectedIndex, withObject: newController)
        tabBarController.viewControllers = controllers
      end
    end
  end
end