class ScreenModuleViewController < UIViewController
  include PM::ScreenModule
  title 'Test Title'

  def self.new(args = {})
    s = self.alloc.initWithNibName(nil, bundle:nil)
    s.screen_init(args) if s.respond_to?(:screen_init)
    s
  end

  def viewDidLoad
    super
    self.view_did_load if self.respond_to?(:view_did_load)
  end

  def viewWillAppear(animated)
    super
    self.view_will_appear(animated) if self.respond_to?("view_will_appear:")
  end

  def viewDidAppear(animated)
    super
    self.view_did_appear(animated) if self.respond_to?("view_did_appear:")
  end

  def viewWillDisappear(animated)
    self.view_will_disappear(animated) if self.respond_to?("view_will_disappear:")
    super
  end

  def viewDidDisappear(animated)
    if self.respond_to?("view_did_disappear:")
      self.view_did_disappear(animated)
    end
    super
  end

  def shouldAutorotateToInterfaceOrientation(orientation)
    self.should_rotate(orientation)
  end

  def shouldAutorotate
    self.should_autorotate
  end

  def willRotateToInterfaceOrientation(orientation, duration:duration)
    self.will_rotate(orientation, duration)
  end

  def didRotateFromInterfaceOrientation(orientation)
    self.on_rotate
  end
end
