### Contents

* [Usage](#usage)
* [Methods](#methods)
* [Class Methods](#class-methods)
* [Accessors](#accessors)

### Usage

```ruby
class AppDelegate < PM::Delegate
  def on_load(app, options)
    open_split_screen MenuScreen.new(nav_bar: true), DetailScreen.new
  end
end
```

### Methods

#### open_split_screen(master, detail, args = {})

*Before iOS 8, iPad apps only*
Opens a UISplitScreenViewController with the specified screens. Usually opened in the AppDelegate as the root view controller.

```ruby
def on_load(app, options)
  open_split_screen MasterScreen, DetailScreen, {
    item: "split-icon", # tab bar item
    title: "Split Screen Title",
    button_title: "Some other title"
  }
end
```

#### create_split_screen(master, detail, args={})

Creates a `PM::SplitViewController` (a `UIViewController` subclass) and returns it. Good for tabbed interfaces.

```ruby
def on_load(app, options)
  @split = create_split_screen(MenuScreen.new(nav_bar: true), DetailScreen)
  open_tab_screen @split, AboutScreen, ContactScreen
end
```

### Class Methods

*None for this module*

### Accessors

#### split_screen

References the containing split screen, if any.

```ruby
# in AppDelegate#on_load...
open_split_screen LeftScreen, RightScreen

# ...

class LeftScreen < PM::Screen
  def on_appear
    self.split_screen # => PM::SplitViewController instance
    self.split_screen.master_screen # => LeftScreen
    self.split_screen.detail_screen # => RightScreen
  end
end
```
