`ProMotion::Tabs` is a module that is automatically included in `PM::Delegate` and `PM::Screen`. It includes methods and functionality dealing with `UITabBarController` and `UITabBarItem`.

* [Methods](#methods)
* [Class Methods](#class-methods)
* [Accessors](#accessors)

### Methods

#### set_tab_bar_item(args)

**NOTE: `icon` and `system_icon` have been deprecated and replaced by `item` and `system_item`.**

Creates the tab that is shown in a tab bar item.
Arguments: `{ item: "imagename", system_item: UITabBarSystemItemContacts, title: "tabtitle" }`

`item` can be a string, in which case it should exist in your resources folder. But `item` can also be a UIImage, if you prefer to create one yourself. Additionally, Apple adds a gradient to every `UITabBarItem`. In order to prevent this, or to control the state of the selected & unselected item, you can pass a hash into `item` like so (where variable `myUIImage` is an instance of `UIImage`):

```ruby
set_tab_bar_item { item: { selected: my_image, unselected: my_image }, title: "tabtitle" }
```

It's recommended to use this method in your `on_init` method OR set it using the class method `tab_bar_item` (below). `on_load` won't be called until you actually load the tab, which is too late.

```ruby
def on_init
  set_tab_bar_item item: "custom_item_5", title: "Custom"
  set_tab_bar_item system_item: :more
  # :more, :favorites, :featured, :top_rated, :recents, :contacts,
  # :history, :bookmarks, :search, :downloads, :most_recent, :most_viewed
end
```

#### open_tab_bar(*screens)

Opens a UITabBarController with the specified screens as the **root view controller** of the current app.
iOS doesn't allow opening a UITabBar as a sub-view. The current screen will be deallocated unless included
as one of the screens in the tab bar.

```ruby
def on_load(app, options)
  open_tab_bar HomeScreen, AboutScreen.new(nav_bar: true), ThirdScreen, HelpScreen
end
```

#### open_tab(tab)

Opens the tab where the "string" title matches the passed in `tab` string. You can also
provide a number (starting at 0) and the tab with that index will be opened.

```ruby
open_tab "About"

open_tab 3 # fourth tab is opened
```

#### on_tab_selected(view_controller)

Provides a hook that is triggered when a tab is selected and passes in the view controller that has been displayed.
Keep in mind that this could be a UINavigationController or other wrapper, so to get the screen
you may need to request `view_controller.topViewController`.

```ruby
def on_tab_selected(view_controller)
  # Do some action
  view_controller.topViewController # => current screen
end
```

### Class Methods

#### tab_bar_item(args={})

Class method that sets the screen's default tab bar item.

```ruby
class TabScreen < PM::Screen
  title "Tab"
  tab_bar_item title: "Tab Item", item: "list", image_insets: [5,5,5,5]
end
```

### Accessors

#### tab_bar

Contains a reference to the current screen's tab bar controller.

#### tab_bar_item

Contains the settings hash used to set up the tab bar item. If you set this manually,
make sure to call `refresh_tab_bar_item` right afterward.
