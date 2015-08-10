module ProMotion
  module Tabs
    attr_accessor :tab_bar, :tab_bar_item

    def open_tab_bar(*screens)
      self.tab_bar = PM::TabBarController.new(screens)
      self.tab_bar.pm_tab_delegate = WeakRef.new(self)

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
      self.tabBarItem = create_tab_bar_item(self.tab_bar_item) if self.tab_bar_item && self.respond_to?("tabBarItem=")
    end

    def set_tab_bar_badge(number)
      self.tab_bar_item[:badge_number] = number
      refresh_tab_bar_item
    end

    def create_tab_bar_item_custom(title, item_image, tag)
      if item_image.is_a?(String)
        item_image = UIImage.imageNamed(item_image)
      elsif item_image.is_a?(Hash)
        item_selected = item_image[:selected]
        item_unselected = item_image[:unselected]
        item_image = nil
      end

      item = UITabBarItem.alloc.initWithTitle(title, image: item_image, tag: tag)

      if item_selected || item_unselected
        item.image = item_unselected
        item.selectedImage = item_selected
      end

      item
    end

    def create_tab_bar_item(tab={})
      if tab[:system_icon]
        mp("`system_icon:` no longer supported. Use `system_item:` instead.", force_color: :yellow)
        tab[:system_item] ||= tab[:system_icon]
      end

      if tab[:icon]
        mp("`icon:` no longer supported. Use `item:` instead.", force_color: :yellow)
        tab[:item] ||= tab[:icon]
      end

      unless tab[:system_item] || tab[:item]
        mp "You must provide either a `system_item:` or custom `item:` in `tab_bar_item`", force_color: :yellow
        abort
      end

      title = tab[:title] || "Untitled"

      tab_bar_item = UITabBarItem.alloc.initWithTabBarSystemItem(map_tab_symbol(tab[:system_item]), tag: current_tag) if tab[:system_item]
      tab_bar_item = create_tab_bar_item_custom(title, tab[:item], current_tag) if tab[:item]

      tab_bar_item.badgeValue = tab[:badge_number].to_s unless tab[:badge_number].nil? || tab[:badge_number] <= 0
      tab_bar_item.imageInsets = tab[:image_insets] if tab[:image_insets]

      tab_bar_item
    end

    def current_tag
      return @prev_tag = 0 unless @prev_tag
      @prev_tag += 1
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
