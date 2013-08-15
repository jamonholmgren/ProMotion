module ProMotion
  module Tabs
    include Conversions
    
    attr_accessor :tab_bar, :tab_bar_item
    
    def open_tab_bar(*screens)
      self.tab_bar = PM::TabBarController.new(screens)

      delegate = self.respond_to?(:open_root_screen) ? self : UIApplication.sharedApplication.delegate

      delegate.open_root_screen(self.tab_bar)
      self.tab_bar
    end

    def open_tab(tab)
      self.tab_bar.open_tab(tab)
    end

    def set_tab_bar_item(args = {})
      self.tab_bar_item = args
      refresh_tab_bar_item
    end

    def refresh_tab_bar_item
      self.tabBarItem = create_tab_bar_item(self.tab_bar_item) if self.tab_bar_item && self.respond_to?(:tabBarItem=)
    end

    def set_tab_bar_badge(number)
      self.tab_bar_item[:badge_number] = number
      refresh_tab_bar_item
    end

    def create_tab_bar_icon(icon, tag)
      return UITabBarItem.alloc.initWithTabBarSystemItem(icon, tag: tag)
    end

    def create_tab_bar_icon_custom(title, icon_image, tag)
      if icon_image.is_a?(String)
        icon_image = UIImage.imageNamed(icon_image)
      elsif icon_image.is_a?(Hash)
        icon_selected = icon_image[:selected]
        icon_unselected = icon_image[:unselected]
        icon_image = nil
      end
      
      item = UITabBarItem.alloc.initWithTitle(title, image:icon_image, tag:tag)

      if icon_selected || icon_unselected
        item.setFinishedSelectedImage(icon_selected, withFinishedUnselectedImage: icon_unselected)
      end

      return item
    end

    def create_tab_bar_item(tab={})
      title = "Untitled"
      title = tab[:title] if tab[:title]
      tab[:tag] ||= @current_tag ||= 0
      @current_tag = tab[:tag] + 1

      tab_bar_item = create_tab_bar_icon(map_tab_symbol(tab[:system_icon]), tab[:tag]) if tab[:system_icon]
      tab_bar_item = create_tab_bar_icon_custom(title, tab[:icon], tab[:tag]) if tab[:icon]

      tab_bar_item.badgeValue = tab[:badge_number].to_s unless tab[:badge_number].nil? || tab[:badge_number] <= 0

      return tab_bar_item
    end
    
    def replace_current_item(tab_bar_controller, view_controller: vc)
      controllers = NSMutableArray.arrayWithArray(tab_bar_controller.viewControllers)
      controllers.replaceObjectAtIndex(tab_bar_controller.selectedIndex, withObject: vc)
      tab_bar_controller.viewControllers = controllers
    end
    
    def map_tab_symbol(symbol)
      @_tab_symbols ||= {
        more:         UITabBarSystemItemMore,
        favorites:    UITabBarSystemItemFavorites,
        featured:     UITabBarSystemItemFeatured,
        top_rated:    UITabBarSystemItemTopRated,
        recents:      UITabBarSystemItemRecents,
        contacts:     UITabBarSystemItemContacts,
        history:      UITabBarSystemItemHistory,
        bookmarks:    UITabBarSystemItemBookmarks,
        search:       UITabBarSystemItemSearch,
        downloads:    UITabBarSystemItemDownloads,
        most_recent:  UITabBarSystemItemMostRecent,
        most_viewed:  UITabBarSystemItemMostViewed
      }
      @_tab_symbols[symbol] || symbol
    end
    
    module TabClassMethods
      def tab_bar_item(args={})
        @tab_bar_item = args
      end
      def get_tab_bar_item
        @tab_bar_item
      end
    end
    
    def self.included(base)
      base.extend(TabClassMethods)
    end
    
  end
end
