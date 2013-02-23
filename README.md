# ProMotion - A new way to easily build RubyMotion apps.

ProMotion introduces a new object called "Screens". Screens have a one-to-one relationship 
with your app's designed screens.


## Table of contents

1. [Tutorials](#tutorials)
  * [Screencasts](#screencasts)
  * [Sample Apps](#sample-apps)
1. **[Getting Started](#getting-started)**
  * [Setup](#setup)
1. [What's New?](#whats-new)
1. [Usage](#usage)
  * [Creating a basic screen](#creating-a-basic-screen)
  * [Loading your first screen](#loading-your-first-screen)
  * [Creating a tab bar](#creating-a-tab-bar)
  * [Adding navigation bar buttons](#add-navigation-bar-buttons)
  * [Opening and closing screens](#opening-and-closing-screens)
  * [Adding view elements](#adding-view-elements)
  * [Table screens](#table-screens)
  * [Using your own UIViewController](#using-your-own-uiviewcontroller)
1. [Reference](#reference)
1. **[Help](#help)**
1. [Contributing](#contributing)

## Tutorials

Version 0.3 tutorial, will be updated soon but most of it still applies:

http://www.clearsightstudio.com/insights/ruby-motion-promotion-tutorial

### Screencasts

Video tutorial with 0.4.

http://www.clearsightstudio.com/insights/tutorial-make-youtube-video-app-rubymotion-promotion/

### Sample apps

Sample app here: https://github.com/jamonholmgren/promotion-tutorial

Also, check out the free [BigDay! Reminder app](https://itunes.apple.com/us/app/bigday!/id571756685?ls=1&mt=8) on the 
App Store to see what's possible. ClearSight Studio built the app for Kijome Software, a small app investment company.

## Getting Started

ProMotion is designed to be as intuitive and Ruby-like as possible. For example, here is a 
typical app folder structure:

    app/
      screens/
        events/
          list_events_screen.rb
          show_event_screen.rb
          edit_event_screen.rb
        home_screen.rb
        settings_screen.rb
      models/
        event.rb
      views/
        buttons/
          save_event_button_view.rb
      app_delegate.rb

### Setup

Create a new RubyMotion project.

`motion create myapp`

Open it in your favorite editor, then go into your Rakefile and add the following to the top:

```ruby
# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require "rubygems"
require 'bundler'
Bundler.require
```


Create a Gemfile and add the following lines:

```ruby
source 'https://rubygems.org'
gem "ProMotion", "~> 0.4.1"
```

Run `bundle install` in Terminal to install ProMotion.

Go into your app/app_delegate.rb file and add the following:

```ruby
class AppDelegate < ProMotion::AppDelegateParent
  def on_load(app, options)
    open HomeScreen.new(nav_bar: true)
  end
end
```

Create a folder in `/app` named `screens`. Create a file in that folder named `home_screen.rb`.

Now drop in this code:

```ruby
class HomeScreen < ProMotion::Screen
  title "Home"
  
  def on_load
    self.view.backgroundColor = UIColor.whiteColor
  end
end
```


Run `rake`. You should now see the simulator open with your home screen and a navigation bar like the image below. Congrats!

![ProMotion Home Screen](http://clearsightstudio.github.com/ProMotion/img/ProMotion/home-screen.png)


## What's New?

* Screens are now UIViewControllers (they used to contain UIViewControllers, but that got too funky) so you can do normal UIViewController stuff with them
* Screen functionality can also be inherited as a module in your own UIViewController, but you need to provide your own methods for viewDidLoad and whatnot.
* Tons of headlessCamelCaps methods are now properly_ruby_underscored (with an alias to the old name for compatibility)
* `open_screen` and `close_screen` can now just be `open` and `close` respectively
* Attempted to keep 100% compatibility with 0.3.x but no guarantees...report issues, please!
* Revamped the internal folder structure of the gem...more work on this to come
* Built in a few helpers that were external before, like `content_height(view)`
* More consistent calling of `on_load` (sometimes doesn't get called in 0.3.x)
* `fresh_start SomeScreen` is now `open_root_screen SomeScreen`
* Removed `set_view_controller` as we don't need it anymore
* Better documentation (still needs work), better error messages
* Deprecation warnings EVERYWHERE for older apps (upgrade already!)


## Usage

### Creating a basic screen

```ruby
class HomeScreen < ProMotion::Screen
  title "Home"

  def on_load
    # Load data
  end
  
  def will_appear
    # Set up the elements in your view with add_element
    @label = add_element UILabel.alloc.initWithFrame(CGRectMake(5, 5, 20, 20))
  end
  
  def on_appear
    # Everything's loaded and visible
  end
end
```

### Loading your first screen

```ruby
# In /app/app_delegate.rb
class AppDelegate < ProMotion::AppDelegate
  def on_load(app, options)
    open MyHomeScreen.new(nav_bar: true)
  end
end
```

### Creating a tab bar

Creating a tabbed bar with multiple screens. This will set the tab bar as the root view controller for your app,
so keep that in mind. It can be done from the AppDelegate#on_load or from a screen (that screen will go away, though).

```ruby
def on_load(app, options)
  @home     = MyHomeScreen.new(nav_bar: true)
  @settings = SettingsScreen.new
  @contact  = ContactScreen.new(nav_bar: true)
  
  open_tab_bar @home, @settings, @contact
end
```

For each screen that belongs to the tab bar, you need to set the tab name and icon in the files. 
In this example, we would need add the following to the three files (my_home_screen.rb, settings_screen.rb, contact_screen.rb):

```ruby
def on_load
  set_tab_bar_item title: "Tab Name Goes Here", icon: "icons/tab_icon.png" # in resources/icons folder
  
  # or...
  set_tab_bar_item system_icon: UITabBarSystemItemContacts
end
```

### Add navigation bar buttons

These two methods add the buttons to the top navigation bar of a screen. The `action:` lets you specify a method to
call when that button is tapped, and you can pass in a UIBarButton style using `type:`.

```ruby
set_nav_bar_right_button "Save", action: :save_something, type: UIBarButtonItemStyleDone
set_nav_bar_left_button "Cancel", action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
```

### Opening and closing screens

If the user taps something and you want to open a new screen, it's easy. Just use `open` and pass in the screen class
or an instance of that screen.

```ruby
def settings_button_tapped
  # ...with a class...
  open SettingsScreen

  # ...or with an instance...
  @settings_screen = SettingsScreen.new
  open @settings_screen
end
```

You can also open a screen as a modal.

```ruby
open SettingsScreen.new, modal: true
```

You can pass in arguments to other screens if they have accessors:

```ruby
class HomeScreen < ProMotion::Screen
  # ...

  def settings_button_tapped
    open ProfileScreen.new(user: some_user)
  end
end

class ProfileScreen < ProMotion::Screen
  attr_accessor :user

  def on_load
    self.user # => some_user instance
  end
end

```

Closing a screen is as easy as can be.

```ruby
# User taps a button, indicating they want to close this screen.
def close_screen_tapped
  close
end
```

You can close a screen (modal or in a nav controller) and pass back arguments to the previous screen's "on_return" method:

```ruby
class ItemScreen < ProMotion::Screen
  # ...
  def save_and_close
    if @model.save
      close(model_saved: true)
    end
  end
end

class MainScreen < ProMotion::Screen
  # ...
  def on_return(args = {})
    if args[:model_saved]
      self.reload_something
    end
  end
end
```

### Adding view elements

Any view item (UIView, UIButton, custom UIView subclasses, etc) can be added to the current view with `add_element`.
`add_element` accepts a second argument which is a hash of attributes that get applied to the element before it is
dropped into the view.

```ruby
@label = add_element UILabel.alloc.initWithFrame(CGRectMake(5, 5, 20, 20)), {
  text: "This is awesome!",
  font: UIFont.systemFontOfSize(18)
}

@element = add_element UIView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20)), {
  backgroundColor: UIColor.whiteColor
}
```

The `set_attributes` method is identical to add_element except that it does not add it to the current view.

```ruby
@element = set_attributes UIView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20)), {
  backgroundColor: UIColor.whiteColor
}
```

### Table Screens

You can create sectioned table screens easily with TableScreen, SectionedTableScreen, and GroupedTableScreen.

```ruby
class SettingsScreen < ProMotion::GroupedTableScreen
  title "Settings"

  def on_load
    add_right_nav_button(label: "Save", action: :save)
    set_tab_bar_item(title: "Settings", icon: "settings.png")
  end
  
  # table_data is automatically called. Use this format in the return value.
  # It's an array of cell groups, each cell group consisting of a title and an array of cells.
  def table_data
    [{
      title: "Your Account",
      cells: [
        { title: "Edit Profile", action: :edit_profile, arguments: { id: 3 } },
        { title: "Log Out", action: :log_out },
        { title: "Notification Settings", action: :notification_settings }
      ]
    }, {
      title: "App Stuff",
      cells: [
        { title: "About", action: :show_about },
        { title: "Feedback", action: :show_feedback }
      ]
    }]
  end

  # This method allows you to create a "jumplist", the index on the right side of the table
  def table_data_index
    # Ruby magic to make an alphabetical array of letters.
    # Try this in Objective-C and tell me you want to go back.
    return ("A".."Z").to_a 
  end
  
  # Your table cells, when tapped, will execute the corresponding actions 
  # and pass in the specified arguments.
  def edit_profile(args={})
    puts args[:id] # => 3
  end
end
```

You can provide remotely downloaded images for cells by including the CocoaPod "SDWebImage" in 
your Rakefile and doing this:

```ruby
  cells: [
    {
      title: "Cell with image",
      remoteImage: { url: "http://placekitten.com/200/300", placeholder: "some-local-image" }
    }
  ]
```

### Using your own UIViewController

Sometimes you want to inherit from a different UIViewController other than that provided by ProMotion,
such as when using [Formotion](https://github.com/clayallsopp/formotion). RubyMotion doesn't currently 
allow us to override built-in methods when including as a module, so there's a workaround for that.

```ruby
class EventsScreen < Formotion::FormController # Can also be < UIViewController
  include ProMotion::ScreenModule # Not TableScreenModule since we're using Formotion for that

  # Required functions for ProMotion to work properly

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

## Reference

<table>
  <tr>
    <th>Class or Module</th>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>Screen</td>
    <td>is_modal?</td>
    <td>Returns if the screen was opened in a modal window.</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>has_nav_bar?</td>
    <td>Returns if the screen is contained in a navigation controller.</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>set_tab_bar_item(args)</td>
    <td>
      Creates the tab that is shown in a tab bar item.<br />
      Arguments: <code>{ icon: "imagename", systemIcon: UISystemIconContacts, title: "tabtitle" }</code>
    </td>
  </tr>  
  <tr>
    <td>&nbsp;</td>
    <td>on_appear</td>
    <td>
      Callback for when the screen appears.<br />
    </td>
  </tr> 
  <tr>
    <td>&nbsp;</td>
    <td>will_appear</td>
    <td>
      Callback for before the screen appears.<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>will_disappear</td>
    <td>
      Callback for before the screen disappears.<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>will_rotate(orientation, duration)</td>
    <td>
      Callback for before the screen rotates.<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>on_opened **Deprecated**</td>
    <td>
      Callback when screen is opened via a tab bar. Please don't use this, as it will be removed in the future<br />
      Use will_appear
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>set_nav_bar_left_button(title, args = {})</td>
    <td>
      Set a left nav bar button.<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>set_nav_bar_right_button(title, args = {})</td>
    <td>
      Set a right nav bar button.<br />
      <img src="http://i.imgur.com/whbkc.png" />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>should_autorotate</td>
    <td>
      iOS 5 return true/false if screen should rotate<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>should_rotate(orientation)</td>
    <td>
      Return true/false for rotation to orientation.<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>supported_orientation?(orientation)</td>
    <td>
      Returns true/false if orientation is in NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].<br />
      Shouldn't need to override this.
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>supported_orientations</td>
    <td>
      Returns supported orientation mask<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>title</td>
    <td>
      Returns title of current screen.<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>title=(title)</td>
    <td>
      Sets title of current screen.<br />
    </td>
  </tr>
  <tr>
    <td>
      ScreenElements<br />
      Included in Screen by default
    </td>
    <td>add_element(view, attrs = {})</td>
    <td>
      Adds the view to the screen after applying the attributes.<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>remove_element</td>
    <td>
      Removes the view from the superview and sets it to nil<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>bounds</td>
    <td>
      Accessor for self.view.bounds<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>frame</td>
    <td>
      Accessor for self.view.frame<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>view</td>
    <td>
      Accessor for self.view<br />
    </td>
  </tr>
  <tr>
    <td>
      SystemHelper<br />
      Included in Screen by default
    </td>
    <td>ios_version</td>
    <td>
      Returns the iOS version that is running on the device<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>ios_version_greater?(version)</td>
    <td>
      Returns true if 'ios_version' is greater than the version passed in, false otherwise<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>ios_version_greater_eq?(version)</td>
    <td>
      Returns true if 'ios_version' is greater than or equal to the version passed in, false otherwise<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>ios_version_is?(version)</td>
    <td>
      Returns true if 'ios_version' is equal to the version passed in, false otherwise<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>ios_version_less?(version)</td>
    <td>
      Returns true if 'ios_version' is less than the version passed in, false otherwise<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>ios_version_less_eq?(version)</td>
    <td>
      Returns true if 'ios_version' is less than or equal to the version passed in, false otherwise<br />
    </td>
  </tr>
  <tr>
    <td>ScreenNavigation<br />
      included in Screen
    </td>
    <td>app_delegate</td>
    <td>
      Returns the AppDelegate<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>close(args = {})</td>
    <td>
      Closes the current screen, passes args back to the previous screen's on_return method<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>open_root_screen(screen)</td>
    <td>
      Closes all other open screens and opens `screen` at the root.<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>open(screen, args = {})</td>
    <td>
      Pushes the screen onto the navigation stack or opens in a modal<br />
      argument options :hide_tab_bar, :modal, any accessors in `screen`
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>open_tab(tab)</td>
    <td>
      Opens the tab where the "string" title is equal to the passed in tab<br />
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>open_tab_bar(*screens)</td>
    <td>
      Open a UITabBarController with the specified screens as the root view controller of the current app<br />
    </td>
  </tr>
</table>

## Help

Ping me on twitter @jamonholmgren or email jamon@clearsightstudio.com, or open a ticket on GitHub.

## Contributing

I'm really looking for feedback. Tweet me with your ideas or open a ticket (I don't mind!) and let's discuss.
