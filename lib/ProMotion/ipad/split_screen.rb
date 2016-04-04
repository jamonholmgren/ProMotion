module ProMotion
  module SplitScreen
    def open_split_screen(master, detail, args={})
      split = create_split_screen(master, detail, args)
      open split, args
      split
    end

    def create_split_screen(master, detail, args={})
      master = master.new if master.respond_to?(:new)
      detail = detail.new if detail.respond_to?(:new)
      split = split_screen_controller(master, detail)
      split_screen_setup(split, args)
      split
    end

    # UISplitViewControllerDelegate methods

    # iOS 7 and below
    def splitViewController(svc, willHideViewController: vc, withBarButtonItem: button, forPopoverController: _)
      button ||= self.displayModeButtonItem if self.respond_to?(:displayModeButtonItem)
      return unless button
      button.title = @pm_split_screen_button_title || vc.title
      svc.detail_screen.navigationItem.leftBarButtonItem = button
    end

    def splitViewController(svc, willShowViewController: _, invalidatingBarButtonItem: _)
      svc.detail_screen.navigationItem.leftBarButtonItem = nil
    end

    # iOS 8 and above
    def splitViewController(svc, willChangeToDisplayMode: display_mode)
      vc = svc.viewControllers.first
      vc = vc.topViewController if vc.respond_to?(:topViewController)
      case display_mode
      # when UISplitViewControllerDisplayModeAutomatic then do_something?
      when UISplitViewControllerDisplayModePrimaryHidden
        self.splitViewController(svc, willHideViewController: vc, withBarButtonItem: nil, forPopoverController: nil)
        # TODO: Add `self.master_screen.try(:will_hide_split_screen)` or similar?
      when UISplitViewControllerDisplayModeAllVisible
        self.splitViewController(svc, willShowViewController: vc, invalidatingBarButtonItem: nil)
        # TODO: Add `self.master_screen.try(:will_show_split_screen)` or similar?
      # when UISplitViewControllerDisplayModePrimaryOverlay
        # TODO: Add `self.master_screen.try(:will_show_split_screen_overlay)` or similar?
      end
    end

  private

    def split_screen_controller(master, detail)
      split = SplitViewController.alloc.init
      split.viewControllers = [ (master.navigationController || master), (detail.navigationController || detail) ]
      split.delegate = self

      [ master, detail ].map { |s| s.split_screen = split if s.respond_to?(:split_screen=) }

      split
    end

    def split_screen_setup(split, args)
      if (args[:item] || args[:title]) && respond_to?(:create_tab_bar_item)
        split.tabBarItem = create_tab_bar_item(args)
      end
      @pm_split_screen_button_title = args[:button_title] if args.has_key?(:button_title)
      split.presentsWithGesture = args[:swipe] if args.has_key?(:swipe)
    end

  end

end
