module ProMotion
  module SplitScreen
    attr_reader :popover_controller

    def split_screen_controller(master, detail)
      master_main = master.navigationController ? master.navigationController : master
      detail_main = detail.navigationController ? detail.navigationController : detail

      split = SplitViewController.alloc.init
      split.viewControllers = [ master_main, detail_main ]
      split.delegate = self

      [ master, detail ].map { |s| s.split_screen = split if s.respond_to?(:split_screen=) }

      split
    end

    def create_split_screen(master, detail, args={})
      master = master.new if master.respond_to?(:new)
      detail = detail.new if detail.respond_to?(:new)

      [ master, detail ].map { |s| s.on_load if s.respond_to?(:on_load) }

      split = split_screen_controller master, detail
      if args.has_key?(:icon) or args.has_key?(:title)
        split.tabBarItem = create_tab_bar_item(args)
      end
      split
    end

    def open_split_screen(master, detail, args={})
      split = create_split_screen(master, detail, args)
      open split, args
      split
    end

    def dismiss_popover
      puts "trying to dismiss popover for #{@popover} : #{@popover.class}"
      _dismiss_popover if @popover_controller
    end

    private
    def _dismiss_popover
      @popover_controller.dismissPopoverAnimated(@popover_controller)
    end

    # UISplitViewControllerDelegate methods

    def splitViewController(svc, willHideViewController: vc, withBarButtonItem: button, forPopoverController: pc)
      puts "willHideViewController: #{vc}"
      button.title = vc.title
      svc.detail_screen.navigationItem.leftBarButtonItem = button;
      @popover_controller = pc
    end

    def splitViewController(svc, willShowViewController: vc, invalidatingBarButtonItem: barButtonItem)
      puts "willShowViewController: #{vc}"
      svc.detail_screen.navigationItem.leftBarButtonItem = nil
      @popover_controller = nil
    end
  end
end
