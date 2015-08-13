module ProMotion
  module NavBarModule

    def nav_bar?
      !!self.navigationController
    end

    def navigation_controller
      self.navigationController
    end

    def navigation_controller=(nav)
      self.navigationController = nav
    end

    def navigationController=(nav)
      @navigationController = nav
    end

    def set_nav_bar_button(side, args={})
      button = (args.is_a?(UIBarButtonItem)) ? args : create_toolbar_button(args)
      button.setTintColor args[:tint_color] if args.is_a?(Hash) && args[:tint_color]

      self.navigationItem.leftBarButtonItem = button if side == :left
      self.navigationItem.rightBarButtonItem = button if side == :right
      self.navigationItem.backBarButtonItem = button if side == :back

      button
    end

    def set_nav_bar_buttons(side, buttons=[])
      buttons = buttons.map{ |b| b.is_a?(UIBarButtonItem) ? b : create_toolbar_button(b) }.reverse

      self.navigationItem.setLeftBarButtonItems(buttons) if side == :left
      self.navigationItem.setRightBarButtonItems(buttons) if side == :right
    end

    # TODO: In PM 2.1+, entirely remove this deprecated method.
    def set_nav_bar_left_button(title, args={})
      mp "set_nav_bar_right_button and set_nav_bar_left_button have been removed. Use set_nav_bar_button :right/:left instead.", force_color: :yellow
    end
    alias_method :set_nav_bar_right_button, :set_nav_bar_left_button

    def set_toolbar_items(buttons = [], animated = true)
      if buttons
        self.toolbarItems = Array(buttons).map{|b| b.is_a?(UIBarButtonItem) ? b : create_toolbar_button(b) }
        navigationController.setToolbarHidden(false, animated:animated)
      else
        navigationController.setToolbarHidden(true, animated:animated)
      end
    end
    alias_method :set_toolbar_buttons, :set_toolbar_items
    alias_method :set_toolbar_button,  :set_toolbar_items

    def add_nav_bar(args = {})
      args = self.class.get_nav_bar.merge(args)
      return unless args[:nav_bar]
      self.navigationController ||= begin
        self.first_screen = true if self.respond_to?(:first_screen=)
        nav = (args[:nav_controller] || NavigationController).alloc.initWithRootViewController(self)
        nav.setModalTransitionStyle(args[:transition_style]) if args[:transition_style]
        nav.setModalPresentationStyle(args[:presentation_style]) if args[:presentation_style]
        nav
      end
      self.navigationController.toolbarHidden = !args[:toolbar] unless args[:toolbar].nil?
    end

    def view_will_appear(animated)
      if @screen_options && !@screen_options[:hide_nav_bar].nil?
        self.navigationController.setNavigationBarHidden(@screen_options[:hide_nav_bar], animated: false)
      end
    end

  private

    def create_toolbar_button(args = {})
      button_type = args[:image] || args[:button] || args[:custom_view] || args[:title] || "Button"
      bar_button_item button_type, args
    end

    def bar_button_item(button_type, args)
      return mp("`system_icon:` no longer supported. Use `system_item:` instead.", force_color: :yellow) if args[:system_icon]
      return button_type if button_type.is_a?(UIBarButtonItem)
      return bar_button_item_system_item(args) if args[:system_item]
      return bar_button_item_image(button_type, args) if button_type.is_a?(UIImage)
      return bar_button_item_string(button_type, args) if button_type.is_a?(String)
      return bar_button_item_custom(button_type) if button_type.is_a?(UIView)
      mp("Please supply a title string, a UIImage or :system.", force_color: :red) && nil
    end

    def bar_button_item_image(img, args)
      button = UIBarButtonItem.alloc.initWithImage(img, style: map_bar_button_item_style(args[:style]), target: args[:target] || self, action: args[:action])
      button.setTintColor args[:tint_color] if args[:tint_color]
      button
    end

    def bar_button_item_string(str, args)
      button = UIBarButtonItem.alloc.initWithTitle(str, style: map_bar_button_item_style(args[:style]), target: args[:target] || self, action: args[:action])
      button.setTintColor args[:tint_color] if args[:tint_color]
      button
    end

    def bar_button_item_system_item(args)
      button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(map_bar_button_system_item(args[:system_item]), target: args[:target] || self, action: args[:action])
      button.setTintColor args[:tint_color] if args[:tint_color]
      button
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
      {
        plain:     UIBarButtonItemStylePlain,
        bordered:  UIBarButtonItemStyleBordered,
        done:      UIBarButtonItemStyleDone
      }[symbol] || UIBarButtonItemStyleDone
    end

  end
end
