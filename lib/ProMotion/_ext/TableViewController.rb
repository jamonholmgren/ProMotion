module ProMotion
  class TableViewController < UITableViewController
    attr_accessor :screen

    def viewDidLoad
      super
      self.screen.view_did_load if self.screen && self.screen.respond_to?(:view_did_load)
    end

    def viewWillAppear(animated)
      super
      self.screen.view_will_appear(animated) if self.screen && self.screen.respond_to?(:view_will_appear)
    end

    def viewDidAppear(animated)
      super
      self.screen.view_did_appear(animated) if self.screen && self.screen.respond_to?(:view_did_appear)
    end
    
    def viewWillDisappear(animated)
      if self.screen && self.screen.respond_to?(:view_will_disappear)
        self.screen.view_will_disappear(animated)
      end
      super      
    end
    
    def viewDidDisappear(animated)
      if self.screen && self.screen.respond_to?(:view_did_disappear)
        self.screen.view_did_disappear(animated)
      end
      super      
    end

    def shouldAutorotateToInterfaceOrientation(orientation)
      self.screen.should_rotate(orientation)
    end

    def willRotateToInterfaceOrientation(orientation, duration:duration)
      self.screen.will_rotate(orientation, duration)
    end
    
    def dealloc
      $stderr.puts "Deallocating #{self.to_s}" if ProMotion::Screen.debug_mode
    end    
  end
end