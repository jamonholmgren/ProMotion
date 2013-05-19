# Using your own UIViewControllers with ProMotion

Sometimes you want to inherit from a different UIViewController other than that provided by ProMotion.
**RubyMotion doesn't currently allow us to override built-in methods when including them as a module.**
And we really need to override `viewDidLoad` and others.

### Formotion

If you're including [Formotion](https://github.com/clayallsopp/formotion), just use the built-in
`PM::FormotionScreen` and provide a `table_data` method or a `form:` object on instantiation.

```ruby
class MyFormScreen < PM::FormotionScreen
  title "My Form"
  
  def table_data
    {
      sections: [{
        title: "Register",
        rows: [{
          title: "Email",
          key: :email,
          placeholder: "me@mail.com",
          type: :email,
          auto_correction: :no,
          auto_capitalization: :none
        }, {
          title: "Password",
          key: :password,
          placeholder: "required",
          type: :string,
          secure: true
        }
      }]
    }
  end
end

# elsewhere...

  open MyFormScreen.new(nav_bar: true)
```

You can also instantiate the form screen with the form hash like Formotion is usually used:

```ruby
  open MyFormScreen.new nav_bar: true, form: {
    sections: [{
      title: "Register",
      rows: [{
        title: "Email",
        key: :email,
        placeholder: "me@mail.com",
        type: :email,
        auto_correction: :no,
        auto_capitalization: :none
      }, {
        title: "Password",
        key: :password,
        placeholder: "required",
        type: :string,
        secure: true
      }
    }]
  }
```

### Custom UIViewController

```ruby
class EventsScreen < UIViewController
  include PM::ScreenModule

  # Required functions for ProMotion to work properly
  def self.new(args = {})
    s = self.alloc.initWithNibName(nil, bundle:nil) # Use your custom initializer if you want.
    s.on_create(args)
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