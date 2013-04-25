module ProMotion
  module SplitScreen
    def create_split_screen(master, detail, args={})
      master = master.new if master.respond_to?(:new)
      detail = detail.new if detail.respond_to?(:new)
      
      split = SplitViewController.alloc.init
      split.viewControllers = [ master, detail ]
      split.delegate = self
      
      [master, detail].each do |s|
        s.split_screen = split if s.respond_to?("split_screen=")
        s.on_load if s.respond_to?(:on_load)
      end

      split
    end
    
    def open_split_screen(master, detail, args={})
      split = create_split_screen(master, detail, args)
      open split, args
      split
    end
    
    def splitViewController(svc, willHideViewController: vc, withBarButtonItem: button, forPopoverController: pc)
      button.title = vc.title
      svc.viewControllers.last.navigationItem.leftBarButtonItem = button;
    end

    def splitViewController(svc, willShowViewController: vc, invalidatingBarButtonItem: barButtonItem)
      svc.viewControllers.last.navigationItem.leftBarButtonItem = nil
    end
  end
end