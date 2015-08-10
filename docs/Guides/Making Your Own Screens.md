You can make your own `PM::Screen` from a custom view controller easily.

### Custom UIViewController

Due to a RubyMotion limitation, we can't override built-in methods with a module. Here are the main methods you'll want to override. You should be able to just copy & paste most of the code below (customize the `self.new` method).

```ruby
  class EventsScreen < JHAwesomeViewController
    include ProMotion::ScreenModule

    # Customize this method for your preferred initializer

    def self.new(args = {})
      s = self.alloc.initWithAwesomeName(args[:name])
      s.screen_init(args) # Important for ProMotion stuff!
      s
    end

    # Highly recommended that you include these methods below
  
    def loadView
      self.respond_to?(:load_view) ? self.load_view : super
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
      self.view_did_disappear(animated) if self.respond_to?("view_did_disappear:")
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
```
