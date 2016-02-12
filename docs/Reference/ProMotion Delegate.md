### Contents

* [Usage](#usage)
* [Methods](#methods)
* [Class Methods](#class-methods)
* [Accessors](#accessors)

### Usage

The PM::Delegate gives you ProMotion's nice API for your AppDelegate class.

```ruby
# app/app_delegate.rb
class AppDelegate < PM::Delegate
  status_bar false, animation: :none

  def on_load(app, options)
    open HomeScreen
  end
end
```

If you need to inherit from a different AppDelegate superclass, do this:

```ruby
class AppDelegate < JHMyParentDelegate
  include PM::DelegateModule
  status_bar false, animation: :none

  def on_load(app, options)
    open HomeScreen
  end
end
```

### Methods

#### on_load(app, options)

Main method called when starting your app. Open your first screen, tab bar, or split view here.

```ruby
def on_load(app, options)
  open HomeScreen
end
```

#### on_unload

Fires when the app is about to terminate. Don't do anything crazy here, but it's a last chance
to save state if necessary.

```ruby
def on_unload
  # Unloading!
end
```

#### will_load(app, options)

Fired just before the app loads. Not usually necessary.

#### will_deactivate

Fires when the app is about to become inactive.

#### on_activate

Fires when the app becomes active.

#### will_enter_foreground

Fires just before the app enters the foreground.

#### on_enter_background

Fires when the app enters the background.

#### open_tab_bar(*screens)

Opens a UITabBarController with the specified screens as the root view controller of the current app.
iOS doesn't allow opening a UITabBar as a sub-view.

```ruby
def on_load(app, options)
  open_tab_bar HomeScreen, AboutScreen, ThirdScreen, HelpScreen
end
```

ProMotion will automatically save the tab bar order for your users if you have more than 5 screens in the UITabBarController. If your project has multiple UITabBarControllers, you need to name them when you create them so that ProMotion knows which one to restore when reopening that UITabBarController:

```ruby
def on_load(app, options)
  my_tab_bar_controller = PM::TabBarController.new(
    HomeScreen,
    AboutScreen,
    ThirdScreen,
    HelpScreen,
    AnotherScreen,
    FinalScreen
  )
  my_tab_bar_controller.name = "my_tab_controllers_name"
  open_tab_bar my_tab_bar_controller
end
```

*note that the order saving goes off of the index of the view controllers added, so if you change the order in which you pass screens to the `PM::TabBarController`, this will mess up any custom order that a user has saved.*

#### open_split_screen(master, detail)

**Before iOS 8, iPad apps only**

Opens a UISplitScreenViewController with the specified screens as the root view controller of the current app

```ruby
def on_load(app, options)
  open_split_screen MasterScreen, DetailScreen,
    icon: "split-icon", title: "Split Screen Title" # optional
end
```

#### on_open_url(args = {})

Fires when the application is opened via a URL (utilizing [application:openURL:sourceApplication:annotation:](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIApplicationDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:openURL:sourceApplication:annotation:)).

```ruby
def on_open_url(args = {})
  args[:url]        # => the URL used to fire the app (NSURL)
  args[:source_app] # => the bundle ID of the app that is launching your app (string)
  args[:annotation] # => hash with annotation data from the source app
end
```

#### on_continue_user_activity(args = {})

Fires when the application is opened with a `NSUserActivity` (utilizing [application:continueUserActivity:restorationHandler:](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:continueUserActivity:restorationHandler:)).

```ruby
def on_continue_user_activity(asrgs = {})
  args[:user_activity]        #=> the object that describes the activity (NSUserActivity)
  args[:restoration_handler]  #=> a block, that yields an array of restorable objects, ie. objects that respond to a `restoreActivityState` method.
end
```

---

### Class Methods

#### status_bar

Class method that allows hiding or showing the status bar. Setting this to `false` will hide it throughout the app.

```ruby
class AppDelegate < PM::Delegate
  status_bar true, animation: :none # :slide, :fade
end
```

If you want the status bar to be hidden on the splash screen you must set this in your rakefile.

```ruby
app.info_plist['UIStatusBarHidden'] = true
```

#### tint_color

Class method that allows you to set the application's global tint color for iOS 7 apps.

```ruby
class AppDelegate < ProMotion::Delegate
  tint_color UIColor.greenColor
end
```

---

### Accessors

#### window

References the UIWindow that is auto-created with the first `open`, `open_tab_bar`, or `open_split_screen` call.

```ruby
def some_method
  self.window #=> UIWindow instance
end
```

#### home_screen

References the root screen for the app.

```ruby
def some_method
  self.home_screen #=> PM::Screen instance
end
```
