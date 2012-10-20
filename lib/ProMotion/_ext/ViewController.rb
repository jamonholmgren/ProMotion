module ProMotion
  class ViewController < UIViewController
    attr_accessor :screen

    def viewDidLoad
      super
      if screen_will_respond_to?(:view_did_load)
        self.screen.view_did_load
      end
    end

    def viewWillAppear(animated)
      super
      if screen_will_respond_to?(:view_will_appear)
        self.screen.view_will_appear(animated)
      end
    end

    def viewDidAppear(animated)
      super
      if screen_will_respond_to?(:view_did_appear)
        self.screen.view_did_appear(animated)
      end
    end

    def viewWillDisappear(animated)
      if screen_will_respond_to?(:view_will_disappear)
        self.screen.view_will_disappear(animated)
      end
      super      
    end
    
    def viewDidDisappear(animated)
      if screen_will_respond_to?(:view_did_disappear)
        self.screen.view_did_disappear(animated)
      end
      super      
    end

    def screen_will_respond_to?(method)
      self.screen && self.screen.respond_to?(method)
    end

    def dealloc
      $stderr.puts "Deallocating #{self.to_s}"
    end
  end
end