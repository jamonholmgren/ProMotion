module ProMotion
  module NavBarModule

    def nav_bar?
      !!self.navigationController
    end

    def navigation_controller
      self.navigationController
    end

    def navigation_controller=(nav)
      @navigationController = nav
    end

    def navigationController=(nav)
      @navigationController = nav
    end

    def add_nav_bar(args = {})
      self.navigationController ||= begin
        self.first_screen = true if self.respond_to?(:first_screen=)
        nav = NavigationController.alloc.initWithRootViewController(self)
        nav.setModalTransitionStyle(args[:transition_style]) if args[:transition_style]
        nav.setModalPresentationStyle(args[:presentation_style]) if args[:presentation_style]
        nav
      end
      self.navigationController.toolbarHidden = !args[:toolbar] unless args[:toolbar].nil?
    end

    def set_nav_bar_button(side, args={})
      button = create_toolbar_button(args)

      self.navigationItem.leftBarButtonItem = button if side == :left
      self.navigationItem.rightBarButtonItem = button if side == :right
      self.navigationItem.backBarButtonItem = button if side == :back

      button
    end

    def create_toolbar_button(args = {})
      args[:system_item] = map_bar_button_system_item(args[:system_item])
      button_type = args[:image] || args[:button] || args[:system_item] || args[:custom_view] || args[:title] || "Button"
      bar_button_item button_type, args
    end

    def set_toolbar_items(buttons = [], animated = true)
      self.toolbarItems = Array(buttons).map{|b| b.is_a?(UIBarButtonItem) ? b : create_toolbar_button(b) }
      navigationController.setToolbarHidden(false, animated:animated)
    end
    alias_method :set_toolbar_buttons, :set_toolbar_items
    alias_method :set_toolbar_button,  :set_toolbar_items

    def bar_button_item(button_type, args)
      case button_type
      when UIBarButtonItem then button_type
      when UIImage then bar_button_item_image(button_type)
      when String then bar_button_item_string(button_type)
      when UIView then bar_button_item_custom(button_type)
      else
        return bar_button_item_system_item(args) if args[:system_item]
        PM.logger.error("Please supply a title string, a UIImage or :system.")
        nil
      end
    end

    def bar_button_item_image(img)
      UIBarButtonItem.alloc.initWithImage(img, style: map_bar_button_item_style(args[:style]), target: args[:target] || self, action: args[:action])
    end

    def bar_button_item_string(str)
      UIBarButtonItem.alloc.initWithTitle(str, style: map_bar_button_item_style(args[:style]), target: args[:target] || self, action: args[:action])
    end

    def bar_button_item_system_item(args)
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(args[:system_item], target: args[:target] || self, action: args[:action])
    end

    def bar_button_item_custom(custom_view)
      UIBarButtonItem.alloc.initWithCustomView(custom_view)
    end

    def map_bar_button_system_item(symbol)
      {
        done:         UIBarButtonSystemItemDone,
        cancel:       UIBarButtonSystemItemCancel,
        edit:         UIBarButtonSystemItemEdit,
        save:         UIBarButtonSystemItemSave,
        add:          UIBarButtonSystemItemAdd,
        flexible_space: UIBarButtonSystemItemFlexibleSpace,
        fixed_space:    UIBarButtonSystemItemFixedSpace,
        compose:      UIBarButtonSystemItemCompose,
        reply:        UIBarButtonSystemItemReply,
        action:       UIBarButtonSystemItemAction,
        organize:     UIBarButtonSystemItemOrganize,
        bookmarks:    UIBarButtonSystemItemBookmarks,
        search:       UIBarButtonSystemItemSearch,
        refresh:      UIBarButtonSystemItemRefresh,
        stop:         UIBarButtonSystemItemStop,
        camera:       UIBarButtonSystemItemCamera,
        trash:        UIBarButtonSystemItemTrash,
        play:         UIBarButtonSystemItemPlay,
        pause:        UIBarButtonSystemItemPause,
        rewind:       UIBarButtonSystemItemRewind,
        fast_forward: UIBarButtonSystemItemFastForward,
        undo:         UIBarButtonSystemItemUndo,
        redo:         UIBarButtonSystemItemRedo,
        page_curl:    UIBarButtonSystemItemPageCurl
      }[symbol] ||    UIBarButtonSystemItemDone
    end

    def map_bar_button_item_style(symbol)
      symbol = {
        plain:    UIBarButtonItemStylePlain,
        bordered: UIBarButtonItemStyleBordered,
        done:     UIBarButtonItemStyleDone
      }[symbol] if symbol.is_a?(Symbol)
      symbol || UIBarButtonItemStyleBordered
    end

  end
end
