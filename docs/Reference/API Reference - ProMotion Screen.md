### Contents

* [Usage](?#usage)
* [Methods](?#methods)
* [Class Methods](?#class-methods)
* [Accessors](?#accessors)

### Usage

PM::Screen is the primary object in ProMotion and a subclass of UIViewController. It adds some abstraction to make your life easier while still allowing the full power of a UIViewController.

```ruby
class HomeScreen < PM::Screen
  title "Home"
  tab_bar_item item: "home-screen-tab", title: "Home"
  status_bar :light

  def on_load
    # set up subviews here
    add MyCustomView, frame: [[ 50, 50 ], [ 100, 100 ]]
    set_nav_bar_button :right, title: "Next", action: :go_to_next
  end

  # custom method, triggered by tapping right nav bar button set above
  def go_to_next
    open NextScreen # opens in same navigation controller, assuming we're in one
  end

  def will_appear
    # just before the view appears
  end

  def on_appear
    # just after the view appears
  end

  def will_disappear
    # just before the view disappears
  end

  def on_disappear
    # just after the view disappears
  end

end
```

---

### Methods

#### app

Returns the `UIApplication.sharedApplication`

```ruby
# Instead of
UIApplication.sharedApplication.someMethod
# Use
app.someMethod
```

#### app_delegate

Returns the `UIApplication.sharedApplication.delegate`

```ruby
# Instead of
UIApplication.sharedApplication.delegate.someMethod
# Use
app_delegate.someMethod
```

#### app_window

Returns the current `app_delegate`s `UIWindow.

```ruby
app_window.addSubview someView
```

### try(method, *args)

Sends `method(*args)` to the current screen if the current screen will `respond_to?(method)`


#### modal?

Returns if the screen was opened in a modal window.

```ruby
m = ModalScreen.new
open_modal m
m.modal? # => true
```

#### nav_bar?

Returns if the screen is currently contained in a navigation controller.

```ruby
open s = HomeScreen.new(nav_bar: true)
s.nav_bar? # => true
```

#### will_appear

Runs before the screen appears.

```ruby
def will_appear
  # just before the screen appears
end
```

#### on_appear

Runs when the screen has appeared.

```ruby
def on_appear
  # screen has just appeared
end
```

#### will_present

Runs just before the screen is pushed onto the navigation controller.

```ruby
def will_present
  # About to present
end
```

#### on_present

Runs just after the screen is pushed onto the navigation controller.

```ruby
def on_present
  # Presented
end
```

#### will_disappear

Runs just before the screen disappears.

#### will_dismiss

Runs just before the screen is removed from its parent. Usually happens when getting popped off a navigation controller stack.

#### on_dismiss

Runs just after the screen is removed from its parent.

#### will_rotate(orientation, duration)

Runs just before the screen rotates.

#### set_nav_bar_button(side, args = {})

Set a nav bar button. `args` can be `image:`, `title:`, `system_item:`, `button:`, `custom_view:`.

You can also set arbitrary attributes in the hash and they'll be applied to the button.

```ruby
set_nav_bar_button :left, {
  title: "Button Title",
  image: UIImage.imageNamed("left-nav"),
  system_item: :reply,
  tint_color: UIColor.blueColor,
  button: UIBarButtonItem.initWithTitle("My button", style: UIBarButtonItemStyleBordered, target: self, action: :tapped_button) # for custom button
}
```

`system_item` can be a `UIBarButtonSystemItem` or one of the following symbols:
```ruby
:done,:cancel,:edit,:save,:add,:flexible_space,:fixed_space,:compose,
:reply,:action,:organize,:bookmarks,:search,:refresh,:stop,:camera,
:trash,:play,:pause,:rewind,:fast_forward,:undo,:redo,:page_curl
```

`custom_view` can be any custom `UIView` subclass you initialize yourself

Another example with arbitrary attributes:

```ruby
set_nav_bar_button :right, {
  system_item: :add,
  action: :add_item,
  accessibility_label: "add item",
  background_color: UIImage.imageNamed("some-image")
}
```

And finally, you can also set the `:back` nav bar image on a screen and it will render a back arrow icon in the upper left part of the navigation. However, note that doing so will change the back button for all descendants of the screen you set the button on. This behavior is a little unintuitive, but is a result of the underlying Cocoa Touch APIs. For example:

```ruby
class MyScreen < PM::Screen
  def on_init
    set_nav_bar_button :back, title: 'Cancel', style: :plain, action: :back
  end

  def go_to_next_screen
    open MyScreenChild
  end
end
```

The code above will add a "cancel" back button to `MyScreenChild` when it is opened as a descendant of `MyScreen`.

#### set_nav_bar_buttons(side, button_array)

Allows you to set multiple buttons on one side of the nav bar with a single method call. The second parameter should be an array of any mixture of UIBarButtonItem instances and hash constructors used in set_nav_bar_button

```ruby
set_nav_bar_buttons :right, [{
  custom_view: my_custom_view_button
},{
  title: "Tasks",
  image: UIImage.imageNamed("whatever"),
  action: nil
}]
```

#### set_toolbar_items(buttons = [], animated = true)

Uses an array to set the navigation controllers toolbar items and shows the toolbar. Uses the same hash formatted parameters as `set_nav_bar_button`. When calling this method, the toolbar will automatically be shown (even if the screen was created without a toolbar). Use the `animated` parameter to specify if the toolbar showing should be animated or not.

```ruby
# Will arrange one button on the left and another on the right
set_toolbar_items [{
    title: "Button Title",
    action: :some_action
  }, {
    system_item: :flexible_space
  }, {
    title: "Another ButtonTitle",
    action: :some_other_action,
    target: some_other_object
  }]
```

You can also pass your own initialized `UIBarButtonItem` as part of the array (instead of a hash object).

_EDGE FEATURE:_ You can pass `tint_color` with a `UIColor` to change the tint color of the button item.

#### title

Returns title of current screen.

```ruby
class MyScreen < PM::Screen
  title "Mine"
  def on_load
    self.title # => "Mine"
  end
```

#### title=(title)

Sets the text title of current screen instance. Note that you must declare `self` as the receiver.

```ruby
class SomeScreen
  def on_load
    # This sets this instance's title
    self.title = "Something else"
  end
end
```

#### app_delegate

Returns the AppDelegate. Alias of `UIApplication.sharedApplication.delegate`.

#### close(args = {})

Closes the current screen, passes `args` back to the previous screen's `on_return` method (if it exists).

```ruby
class ChildScreen < PM::Screen
  def save_and_close
    save
    close({ saved: true })
  end
end

class ParentScreen < PM::Screen
  def on_return(args={})
    if args[:saved]
      reload_data
    end
  end
end
```

If you want to close back to the root screen or any other screen in the navigation stack, use `to_screen:`:

```ruby
class ChildScreen < PM::Screen
  def close_to_root
    close to_screen: self.navigation_controller.viewControllers.first
    # For the rootViewController, you can just use `:root`
    close to_screen: :root
  end
end
```

#### open_root_screen(screen)

Closes all other open screens and opens `screen` as the root view controller.

```ruby
def reset_this_app
  open_root_screen HomeScreen
end
```

#### open(screen, args = {})

Opens a screen, intelligently determining the context.

**Examples:**

```ruby
# In app delegate
open HomeScreen.new(nav_bar: true)

# In tab bar
open HomeScreen.new(nav_bar: true), hide_tab_bar: true

# `modal: true` is the same as `open_modal`.
open ModalScreen.new(nav_bar: true), modal: true, animated: true

# Opening a modal screen with transition or presentation styles
open_modal ModalScreen.new(nav_bar: true,
    transition_style: UIModalTransitionStyleFlipHorizontal,
    presentation_style: UIModalPresentationFormSheet)

# From any screen (same as `open_root_screen`)
open HomeScreen.new(nav_bar: true), close_all: true

# Opening a screen in a different tab or split view screen
open DetailScreen.new, in_tab: "Tab name" # if you're in a tab bar
open MasterScreen, in_master: true # if you're in a split view (opened in current navigation controller if not)
open DetailScreen, in_detail: true # if you're in a split view (opened in current navigation controller if not)

# Opening a screen with a custom navigation_controller class. (Defaults to PM::NavigationController)
class MyNavigationController < PM::NavigationController; end
open HomeScreen.new(nav_bar: true, nav_controller: MyNavigationController), close_all: true

# Opens a screen with a navigation controller but with the navigation bar hidden
open HomeScreen.new(nav_bar: true, hide_nav_bar: true) # Edge feature
```

##### Setting screen accessors

Any writable attribute (accessor, setter methods etc.) in `screen` can also be set in the `new` hash argument.

```ruby
class HomeScreen < PM::Screen
  def profile_button_tapped
    open ProfileScreen.new(user: @current_user)
  end
end

class ProfileScreen < PM::Screen
  attr_accessor :user

  def on_load
    puts user # => @current_user object
  end
end
```

#### open_modal(screen, args = {})

Opens a modal screen. Same as `open HomeScreen, modal: true`

#### should_autorotate

(iOS 6+) return true/false if screen should rotate.
Defaults to true.

#### should_rotate(orientation)

(iOS 5) Return true/false for rotation to orientation. Tries to resolve this automatically
from your `UISupportedInterfaceOrientations` setting. You normally don't override this method.

#### supported_orientation?(orientation)

Returns whether `UISupportedInterfaceOrientations` includes the given orientation.

```ruby
supported_orientation?(UIInterfaceOrientationMaskPortrait)
supported_orientation?(UIInterfaceOrientationMaskLandscapeLeft)
supported_orientation?(UIInterfaceOrientationMaskLandscapeRight)
supported_orientation?(UIInterfaceOrientationMaskPortraitUpsideDown)
```

#### supported_orientations

Returns the value for `UISupportedInterfaceOrientations`.

#### will_rotate(orientation, duration)

Runs just before the device is rotated.

#### on_rotate

Runs just after the device is rotated.

#### supported_device_families

Returns either `:iphone` or `:ipad`. Should probably be named `current_device_family` or something.

#### first_screen?

Boolean representing if this is the first screen in a navigation controller stack.

```ruby
def on_appear
  self.first_screen? # => true | false
end
```

---

### Class Methods

#### title(new_title)

Sets the default text title for all of this screen's instances

```ruby
class MyScreen < PM::Screen
  title "Some screen"
  # ...
end
```

#### title_view(new_title_view)

Sets an arbitrary view as the nav bar title.

```ruby
class MyScreen < PM::Screen
  title_view UILabel.new
  # ...
end
```

#### title_image(new_image)

Sets an arbitrary image as the nav bar title.

```ruby
class MyScreen < PM::Screen
  title_image "image.png"
  # ...
end
```

#### status_bar(style=nil, args={animation: UIStatusBarAnimationSlide})

Set the properties of the applications' status bar. Options for style are: `:none`, `:light` and `:default`. The animation argument should be a `UIStatusBarAnimation` (or `:none` / `:fade` / `:slide`) and is used to hide or show the status bar when appropriate and defaults to `:slide`.

```ruby
class MyScreen < PM::Screen
  status_bar :none, {animation: :fade}
  # ...
end

class MyScreenWithADarkColoredNavBar < PM::Screen
  status_bar :light
  # ...
end
```

#### nav_bar_button(position, button_options)

Creates a nav bar button in the specified position with the given options

```ruby
class HomeScreen < PM::Screen
  nav_bar_button :left, title: "Back", style: :plain, action: :back
  # ...
end
```

---

### Accessors

#### parent_screen

References the screen immediately before this one in a navigation controller *or* the presenting
screen for modals. You should set this yourself if you're doing something funky like `addChildViewController`.

```ruby
def on_appear
  self.parent_screen # => PM::Screen instance
end
```

#### view

The main view for this screen.

#### bounds

Alias for self.view.bounds

#### frame

Alias for self.view.frame
