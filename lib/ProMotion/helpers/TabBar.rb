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




      def create_tab_bar_controller_from_data(data)
        data = self.setTags(data)

        tabBarController = UITabBarController.alloc.init
        tabBarController.viewControllers = self.tabControllersFromData(data)

        return tabBarController
      end

      def set_tags(data)
        tag_number = 0
        
        data.each do |d|
          d[:tag] = tag_number
          tag_number += 1
        end

        return data
      end

      def tab_bar_icon(icon, tag)
        return UITabBarItem.alloc.initWithTabBarSystemItem(icon, tag: tag)
      end

      def tab_bar_icon_custom(title, image_name, tag)
        icon_image = UIImage.imageNamed(image_name)
        return UITabBarItem.alloc.initWithTitle(title, image:icon_image, tag:tag)
      end

      def tab_controllers_from_data(data)
        mt_tab_controllers = []

        data.each do |tab|
          mt_tab_controllers << self.controller_from_tab_data(tab)
        end

        return mt_tab_controllers
      end

      def controller_from_tab_data(tab)
        tab[:badgeNumber] = 0 unless tab[:badgeNumber]
        tab[:tag] = 0 unless tab[:tag]
        
        view_controller = tab[:view_controller]
        view_controller = tab[:view_controller].alloc.init if tab[:view_controller].respond_to?(:alloc)
        
        if tab[:navigationController]
          controller = UINavigationController.alloc.initWithRootViewController(view_controller)
        else
          controller = view_controller
        end

        controller.tabBarItem = self.tabBarItem(tab)
        controller.tabBarItem.title = controller.title unless tab[:title]

        return controller
      end

      def tab_bar_item(tab)
        title = "Untitled"
        title = tab[:title] if tab[:title]
        tab[:tag] ||= 0

        tab_bar_item = tab_bar_icon(tab[:systemIcon], tab[:tag]) if tab[:systemIcon]
        tab_bar_item = tab_bar_icon_custom(title, tab[:icon], tab[:tag]) if tab[:icon]
        
        tab_bar_item.badgeValue = tab[:badgeNumber].to_s unless tab[:badgeNumber].nil? || tab[:badgeNumber] <= 0
        
        return tab_bar_item
      end

      def select(tab_bar_controller, title: title)
        root_controller = nil
        tab_bar_controller.viewControllers.each do |vc|
          if vc.tabBarItem.title == title
            tab_bar_controller.selectedIndex = vc.tabBarItem.tag
            root_controller = vc
            break
          end
        end
        root_controller
      end

      def select(tab_bar_controller, tag: tag)
        tab_bar_controller.selectedIndex = tag
      end

      def replace_current_item(tab_bar_controller, view_controller: vc)
        controllers = NSMutableArray.arrayWithArray(tab_bar_controller.viewControllers)
        controllers.replaceObjectAtIndex(tab_bar_controller.selectedIndex, withObject: vc)
        tab_bar_controller.viewControllers = controllers
      end
    end
  end
end