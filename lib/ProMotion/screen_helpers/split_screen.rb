module ProMotion
  module SplitScreen
    def open_split_screen(master, child, args={})
      master = master.new if master.respond_to?(:new)
      child = child.new if child.respond_to?(:new)
      
      split = SplitViewController.alloc.init
      split.viewControllers = [ master, child ]
      split.delegate = self
      
      open split
      split
    end
    
    # This is why you're using ProMotion. You don't want to write method defs like this.
    def splitViewController(svc, willHideViewController: vc, withBarButtonItem: button, forPopoverController: pc)
      button.title = vc.title
      svc.viewControllers.last.navigationItem.leftBarButtonItem = button;
    end

    def splitViewController(svc, willShowViewController: vc, invalidatingBarButtonItem: barButtonItem)
      svc.viewControllers.last.navigationItem.leftBarButtonItem = nil
    end
  end
end