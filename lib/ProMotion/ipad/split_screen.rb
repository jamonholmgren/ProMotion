module ProMotion
  # @requires class:SplitViewController
  module SplitScreen
    def split_screen_controller(master, detail)
      split = SplitViewController.alloc.init
      split.viewControllers = [ (master.navigationController || master), (detail.navigationController || detail) ]
      split.delegate = self

      [ master, detail ].map { |s| s.split_screen = split if s.respond_to?(:split_screen=) }

      split
    end

    def create_split_screen(master, detail, args={})
      master = master.new if master.respond_to?(:new)
      detail = detail.new if detail.respond_to?(:new)
      split = split_screen_controller(master, detail)
      split_screen_setup(split, args)
      split
    end

    def open_split_screen(master, detail, args={})
      split = create_split_screen(master, detail, args)
      open split, args
      split
    end

    # UISplitViewControllerDelegate methods

    def splitViewController(svc, willHideViewController: vc, withBarButtonItem: button, forPopoverController: pc)
      button.title = @pm_split_screen_button_title || vc.title
      svc.detail_screen.navigationItem.leftBarButtonItem = button
    end

    def splitViewController(svc, willShowViewController: vc, invalidatingBarButtonItem: barButtonItem)
      svc.detail_screen.navigationItem.leftBarButtonItem = nil
    end

  private

    def split_screen_setup(split, args)
      if (args[:icon] || args[:title]) && respond_to?(:create_tab_bar_item)
        split.tabBarItem = create_tab_bar_item(args)
      end
      @pm_split_screen_button_title = args[:button_title] if args.has_key?(:button_title)
      split.presentsWithGesture = args[:swipe] if args.has_key?(:swipe)
    end

  end

end
