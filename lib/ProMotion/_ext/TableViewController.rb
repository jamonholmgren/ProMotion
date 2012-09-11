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

  end
end