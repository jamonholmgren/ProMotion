module ProMotion
  class TabBar
    class << self
      def tab_bar_item(args = {})
        title = "Untitled"
        title = args[:title] if args[:title]
        args[:tag] ||= 0

        tb_item = tab_bar_icon(args[:system_icon], args[:tag]) if args[:system_icon]
        tb_item = tab_bar_icon_custom(title, args[:icon], args[:tag]) if args[:icon]
        
        if tb_item
          tb_item.badgeValue = args[:badge_number].to_s unless args[:badge_number].nil? || tab[:badge_number] <= 0

          return tb_item
        end
        nil
      end

      def tab_bar_icon(icon, tag)
        return UITabBarItem.alloc.initWithTabBarSystemItem(icon, tag: tag)
      end

      def tab_bar_icon_custom(title, image_name, tag)
        icon_image = UIImage.imageNamed(image_name)
        return UITabBarItem.alloc.initWithTitle(title, image:icon_image, tag:tag)
      end
    end
  end
end