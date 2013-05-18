# ProMotion [![Build Status](https://travis-ci.org/clearsightstudio/ProMotion.png)](https://travis-ci.org/clearsightstudio/ProMotion)

## A new way to easily build RubyMotion apps.

ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.

**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [ProMotion ](#promotion-)
  - [A new way to easily build RubyMotion apps.](#a-new-way-to-easily-build-rubymotion-apps)
- [Tutorials](#tutorials)
  - [Screencasts](#screencasts)
  - [Sample Apps](#sample-apps)
  - [Apps Built With ProMotion](#apps-built-with-promotion)
    - [BigDay! Reminder App](#bigday-reminder-app)
    - [TipCounter App](#tipcounter-app)
- [Getting Started](#getting-started)
  - [Setup](#setup)
- [What's New?](#whats-new)
  - [Version 0.6](#version-06)
- [Usage](#usage)
  - [Creating a basic screen](#creating-a-basic-screen)
  - [Loading your first screen](#loading-your-first-screen)
  - [Creating a split screen (iPad apps only)](#creating-a-split-screen-ipad-apps-only)
  - [Creating a tab bar](#creating-a-tab-bar)
  - [Add navigation bar buttons](#add-navigation-bar-buttons)
  - [Opening and closing screens](#opening-and-closing-screens)
    - [Note about split screens and universal apps](#note-about-split-screens-and-universal-apps)
  - [Adding view elements](#adding-view-elements)
  - [Table Screens](#table-screens)
  - [Using your own UIViewController](#using-your-own-uiviewcontroller)
- [Reference](#reference)
  - [Screen](#screen)
  - [TableScreen](#tablescreen)
  - [Logger](#logger)
  - [Console [deprecated]](#console-deprecated)
- [Help](#help)
- [Contributing](#contributing)
  - [Working on Features](#working-on-features)
  - [Submitting a Pull Request](#submitting-a-pull-request)
  - [Primary Contributors](#primary-contributors)

# Tutorials

http://www.clearsightstudio.com/insights/ruby-motion-promotion-tutorial

## Screencasts

http://www.clearsightstudio.com/insights/tutorial-make-youtube-video-app-rubymotion-promotion/

## Sample Apps

This is pretty bare-bones, but we'll be building it out as we go along.

[https://github.com/jamonholmgren/promotion-demo](https://github.com/jamonholmgren/promotion-demo)

## Apps Built With ProMotion

### BigDay! Reminder App
Check out the free [BigDay! Reminder app](https://itunes.apple.com/us/app/bigday!/id571756685?ls=1&mt=8) on the
App Store to see what's possible. ClearSight Studio built the app for Kijome Software, a small app investment company.

### TipCounter App
[TipCounter](http://www.tipcounterapp.com) was built by [Matt Brewer](https://github.com/macfanatic/) for bartenders and servers to easily track their tips.  Used ProMotion and the development was a lot of fun!

### Winston-Salem Crime Map
Have an interest in crime statistics and locations? Live in Winston-Salem, NC? This hyper-local and [open source](https://github.com/markrickert/WSCrime) RubyMotion app uses a mixture custom UIViewControllers and ProMotion for ease of attribute setting and adding views. Check it out [on the App Store](http://www.mohawkapps.com/winston-salem-crime-map/download/) or [fork it and contribute](https://github.com/markrickert/WSCrime)!

# Getting Started

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
          save_event_button.rb
      app_delegate.rb

## Setup

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
gem "ProMotion", "~> 0.6.0"
```

Run `bundle install` in Terminal to install ProMotion.

Go into your app/app_delegate.rb file and replace everything with the following:

```ruby
class AppDelegate < ProMotion::Delegate
  def on_load(app, options)
    open HomeScreen.new(nav_bar: true)
  end
end
```

Make sure you remove the `didFinishLoadingWithOptions` method or call `super` in it. Otherwise
ProMotion won't get set up and `on_load` won't be called.

Create a folder in `/app` named `screens`. Create a file in that folder named `home_screen.rb`.

Now drop in this code:

```ruby
class HomeScreen < ProMotion::Screen
  title "Home"

  def will_appear
    set_attributes self.view, {
      backgroundColor: UIColor.whiteColor
    }
  end
end
```


Run `rake`. You should now see the simulator open with your home screen and a navigation bar like the image below. Congrats!

![ProMotion Home Screen](http://clearsightstudio.github.com/ProMotion/img/ProMotion/home-screen.png)


# What's New?

## Version 0.6

* Will auto-detect if you've loaded [motion-xray](https://github.com/colinta/motion-xray) and enable it.
* Added `open_split_screen` for iPad-supported apps (thanks @rheoli for your contributions to this)
* Added `refreshable` to TableScreens (thanks to @markrickert) for pull-to-refresh support.
* `ProMotion::AppDelegateParent` renamed to `ProMotion::Delegate` (`AppDelegateParent` is an alias)
* `set_attributes` and `add` now apply nested attributes recursively
* `set_attributes` and `add` now accept snake_case instead of camelCase methods (e.g., background_color)
* Added `add_to` method for adding views to any parent view. `remove` works with this normally.
* Deprecated Console.log and replaced with PM::Logger
* Many improvements to how screens and navigation controllers are loaded, tests

# Usage

## Creating a basic screen

```ruby
class HomeScreen < ProMotion::Screen
  title "Home"

  def on_load
    # Load data
  end

  def will_appear
    # Set up the elements in your view with add
    @label ||= add UILabel.alloc.initWithFrame(CGRectMake(5, 5, 20, 20))
  end

  def on_appear
    # Everything's loaded and visible
  end
end
```

## Loading your first screen

```ruby
# In app/app_delegate.rb
class AppDelegate < ProMotion::Delegate
  def on_load(app, options)
    open MyHomeScreen.new(nav_bar: true)
  end
end
```

## Creating a split screen (iPad apps only)

```ruby
# In app/app_delegate.rb
class AppDelegate < ProMotion::Delegate
  def on_load(app, options)
    open_split_screen MenuScreen, DetailScreen
  end
end
```

## Creating a tab bar

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

To programmatically switch to a different tab, use `open_tab`.

```ruby
def some_action
  open_tab "Contacts"
end
```

## Add navigation bar buttons

These two methods add the buttons to the top navigation bar of a screen. The `action:` lets you specify a method to
call when that button is tapped, and you can pass in a UIBarButton style using `type:`.

```ruby
set_nav_bar_right_button "Save", action: :save_something, type: UIBarButtonItemStyleDone
set_nav_bar_left_button "Cancel", action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
```

If you pass an instance of a `UIImage`, the `UIBarButton` will automatically display with that image instead of text. *Don't forget retina and landscape versions of your image!*

If you pass `:system` for the title, then you can get a system item. E.g.:

```ruby
set_nav_bar_right_button nil, action: :add_something, system_icon: UIBarButtonSystemItemAdd
```

Additionally, if you pass an instance of a `UIBarButtonItem`, the `UIBarButton` will automatically display that particular button item.

```ruby
set_nav_bar_left_button self.editButtonItem
```

## Opening and closing screens

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

### Note about split screens and universal apps

It's common to want to open a screen in the same navigation controller if on iPhone but
in a separate detail view when on iPad. Here's a good way to do that.

```ruby
class MenuScreen < ProMotion::TableScreen
  # ...
  def some_action
    open SomeScreen.new, in_detail: true
  end
end
```

The `in_detail` option tells ProMotion to look for a split screen and open in the detail screen
if it's available. If not, open normally. This also works for `in_master:`.

## Adding view elements

Any view item (UIView, UIButton, custom UIView subclasses, etc) can be added to the current view with `add`.
`add` accepts a second argument which is a hash of attributes that get applied to the element before it is
dropped into the view.

`add(view, attr={})`

```ruby
@label = add UILabel.new, {
  text: "This is awesome!",
  font: UIFont.systemFontOfSize(18),
  resize: [ :left, :right, :top, :bottom, :width, :height ], # autoresizingMask
  left: 5, # These four attributes are used with CGRectMake
  top: 5,
  width: 20,
  height: 20
}

@element = add UIView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20)), {
  backgroundColor: UIColor.whiteColor
}
```

The `set_attributes` method is identical to add except that it does not add it to the current view.
If you use snake_case and there isn't an existing method, it'll try camelCase. This allows you to
use snake_case for Objective-C methods.

`set_attributes(view, attr={})`

```ruby
@element = set_attributes UIView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20)), {
  # `background_color` is translated to `backgroundColor` automatically.
  background_color: UIColor.whiteColor
}
```

You can use `add_to` to add a view to any other view, not just the main view.

`add_to(parent_view, new_view, attr={})`

```ruby
add_to @some_parent_view, UIView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20)), {
  backgroundColor: UIColor.whiteColor
}
```

## Table Screens

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
      remote_image: { url: "http://placekitten.com/200/300", placeholder: "some-local-image" }
    }
  ]
```

## Using your own UIViewController

Sometimes you want to inherit from a different UIViewController other than that provided by ProMotion,
such as when using [Formotion](https://github.com/clayallsopp/formotion). **RubyMotion doesn't currently
allow us to override built-in methods when including them as a module.** And we really need to override
`viewDidLoad` and others.

Fortunately, there's a workaround for that.

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

# Reference

## Screen

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>is_modal?</td>
    <td>Returns if the screen was opened in a modal window.</td>
  </tr>
  <tr>
    <td>self</td>
    <td>Returns the Screen which is a subclass of UIViewController or UITableViewController</td>
  </tr>
  <tr>
    <td>has_nav_bar?</td>
    <td>Returns if the screen is contained in a navigation controller.</td>
  </tr>
  <tr>
    <td>set_tab_bar_item(args)</td>
    <td>
      Creates the tab that is shown in a tab bar item.<br />
      Arguments: <code>{ icon: "imagename", systemIcon: UISystemIconContacts, title: "tabtitle" }</code>
    </td>
  </tr>
  <tr>
    <td>on_appear</td>
    <td>
      Callback for when the screen appears.<br />
    </td>
  </tr>
  <tr>
    <td>will_appear</td>
    <td>
      Callback for before the screen appears.<br />
      This is a good place to put your view constructors, but be careful that
      you don't add things more than on subsequent screen loads.
    </td>
  </tr>
  <tr>
    <td>will_disappear</td>
    <td>
      Callback for before the screen disappears.<br />
    </td>
  </tr>
  <tr>
    <td>will_rotate(orientation, duration)</td>
    <td>
      Callback for before the screen rotates.<br />
    </td>
  </tr>
  <tr>
    <td>on_opened **Deprecated**</td>
    <td>
      Callback when screen is opened via a tab bar. Please don't use this, as it will be removed in the future<br />
      Use will_appear
    </td>
  </tr>
  <tr>
    <td>set_nav_bar_left_button(title, args = {})</td>
    <td>
      Set a left nav bar button.<br />
      `title` can be a `String` or a `UIImage`.
    </td>
  </tr>
  <tr>
    <td>set_nav_bar_right_button(title, args = {})</td>
    <td>
      Set a right nav bar button.<br />
      `title` can be a `String` or a `UIImage`.<br />
      <img src="http://i.imgur.com/whbkc.png" />
    </td>
  </tr>
  <tr>
    <td>should_autorotate</td>
    <td>
      (iOS 6) return true/false if screen should rotate.<br />
      Defaults to true.
    </td>
  </tr>
  <tr>
    <td>should_rotate(orientation)</td>
    <td>
      (iOS 5) Return true/false for rotation to orientation.<br />
    </td>
  </tr>
  <tr>
    <td>title</td>
    <td>
      Returns title of current screen.<br />
    </td>
  </tr>
  <tr>
    <td>title=(title)</td>
    <td>
      Sets title of current screen.<br />
      You can also set the title like this (not in a method, though):<br />
<pre><code>
class SomeScreen
  title "Some screen"

  def on_load
    # ...
  end
end
</code></pre>
    </td>
  </tr>
  <tr>
    <td>add(view, attrs = {})</td>
    <td>
      Adds the view to the screen after applying the attributes.<br />
      (alias: `add_element`, `add_view`)<br />
      Example:
      <code>
        add UIInputView.alloc.initWithFrame(CGRectMake(10, 10, 300, 40)), {
          backgroundColor: UIColor.grayColor
        }
      </code>
    </td>
  </tr>
  <tr>
    <td>remove(view)</td>
    <td>
      Removes the view from the superview and sets it to nil<br />
      (alias: `remove_element`, `remove_view`)
    </td>
  </tr>
  <tr>
    <td>bounds</td>
    <td>
      Accessor for self.view.bounds<br />
    </td>
  </tr>
  <tr>
    <td>frame</td>
    <td>
      Accessor for self.view.frame<br />
    </td>
  </tr>
  <tr>
    <td>view</td>
    <td>
      The main view for this screen.<br />
    </td>
  </tr>
  <tr>
    <td>ios_version</td>
    <td>
      Returns the iOS version that is running on the device<br />
    </td>
  </tr>
  <tr>
    <td>app_delegate</td>
    <td>
      Returns the AppDelegate<br />
    </td>
  </tr>
  <tr>
    <td>close(args = {})</td>
    <td>
      Closes the current screen, passes args back to the previous screen's <code>on_return</code> method<br />
    </td>
  </tr>
  <tr>
    <td>open_root_screen(screen)</td>
    <td>
      Closes all other open screens and opens <code>screen</code> as the root view controller.<br />
    </td>
  </tr>
  <tr>
    <td>open(screen, args = {})</td>
    <td>
      Pushes the screen onto the navigation stack or opens in a modal<br />
      Argument options:<br />
      <code>nav_bar: true|false</code><br />
      <code>hide_tab_bar: true|false</code><br />
      <code>modal: true|false</code><br />
      <code>close_all: true|false</code> (closes all open screens and opens as root...same as open_root_screen)<br />
      <code>animated: true:false</code> (currently only affects modals)<br />
      <code>in_tab: "Tab name"</code> (if you're in a tab bar)<br />
      Any accessors in <code>screen</code> can also be set in this hash.
    </td>
  </tr>
  <tr>
    <td>open_split_screen(master, detail)</td>
    <td>
      *iPad apps only*
      Opens a UISplitScreenViewController with the specified screens as the root view controller of the current app<br />
    </td>
  </tr>
  <tr>
    <td>open_tab_bar(*screens)</td>
    <td>
      Opens a UITabBarController with the specified screens as the root view controller of the current app<br />
    </td>
  </tr>
  <tr>
    <td>open_tab(tab)</td>
    <td>
      Opens the tab where the "string" title matches the passed in tab<br />
    </td>
  </tr>
</table>

## TableScreen

*Has all the methods of Screen*

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>searchable(placeholder: "placeholder text")</td>
    <td>Class method to make the current table searchable.</td>
  </tr>
  <tr>
    <td><pre><code>refreshable(
  callback: :on_refresh,
  pull_message: "Pull to refresh",
  refreshing: "Refreshing data…",
  updated_format: "Last updated at %s",
  updated_time_format: "%l:%M %p"
)</code></pre></td>
    <td>Class method to make the current table refreshable.
    	<p>All parameters are optional. If you do not specify a a callback, it will assume you've implemented an <code>on_refresh</code> method in your tableview.</p>
    <pre><code>def on_refresh
  # Code to start the refresh
end</code></pre>
    <p>And after you're done with your asyncronous process, call <code>end_refreshing</code> to collapse the refresh  view and update the last refreshed time and then <code>update_table_data</code>.</p></td>
    <img src="https://f.cloud.github.com/assets/139261/472574/af268e52-b735-11e2-8b9b-a9245b421715.gif" />
  </tr>
  <tr>
    <td colspan="2">
      <h3>table_data</h3>
      Method that is called to get the table's cell data and build the table.<br />
      Example format using nearly all available options.<br />
      <strong>Note...</strong> if you're getting crazy deep into styling your table cells,
      you really should be subclassing them and specifying that new class in <code>:cell_class</code>
      and then providing <code>:cell_class_attributes</code> to customize it.<br /><br />
      <strong>Performance note...</strong> It's best to build this array in a different method
      and store it in something like <code>@table_data</code>. Then your <code>table_data</code>
      method just returns that.

<pre><code>
def table_data
  [{
    title: "Table cell group 1",
    cells: [{
      title: "Simple cell",
      action: :this_cell_tapped,
      arguments: { id: 4 }
    }, {
      title: "Crazy Full Featured Cell",
      subtitle: "This is way too huge..see note",
      arguments: { data: [ "lots", "of", "data" ] },
      action: :tapped_cell_1,
      height: 50, # manually changes the cell's height
      cell_style: UITableViewCellStyleSubtitle,
      cell_identifier: "Cell",
      cell_class: ProMotion::TableViewCell,
      masks_to_bounds: true,
      background_color: UIColor.whiteColor,
      selection_style: UITableViewCellSelectionStyleGray,
      cell_class_attributes: {
        # any Obj-C attributes to set on the cell
        backgroundColor: UIColor.whiteColor
      },
      accessory: :switch, # currently only :switch is supported
      accessory_view: @some_accessory_view,
      accessory_type: UITableViewCellAccessoryCheckmark,
      accessory_checked: true, # whether it's "checked" or not
      image: { image: UIImage.imageNamed("something"), radius: 15 },
      remote_image: {  # remote image, requires SDWebImage CocoaPod
        url: "http://placekitten.com/200/300", placeholder: "some-local-image",
        size: 50, radius: 15
      },
      subviews: [ @some_view, @some_other_view ] # arbitrary views added to the cell
    }]
  }, {
    title: "Table cell group 2",
    cells: [{
      title: "Log out",
      action: :log_out
    }]
  }]
end
</code></pre>
      <img src="http://clearsightstudio.github.com/ProMotion/img/ProMotion/full-featured-table-screen.png" />
    </td>
  </tr>
  <tr>
    <td>update_table_data</td>
    <td>
      Causes the table data to be refreshed, such as when a remote data source has
      been downloaded and processed.<br />
    </td>
  </tr>
</table>

## Logger

*Accessible from ProMotion.logger or PM.logger ... you can also set a new logger by setting `PM.logger = MyLogger.new`*

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>log(label, message_text, color)</td>
    <td>
      Output a colored console message.<br />
      Example: <code>PM.logger.log("TESTING", "This is red!", :red)</code>
    </td>
  </tr>
  <tr>
    <td>error(message)</td>
    <td>
      Output a red colored console error.<br />
      Example: <code>PM.logger.error("This is an error")</code>
    </td>
  </tr>
  <tr>
    <td>deprecated(message)</td>
    <td>
      Output a yellow colored console deprecated.<br />
      Example: <code>PM.logger.deprecated("This is a deprecation warning.")</code>
    </td>
  </tr>
  <tr>
    <td>warn(message)</td>
    <td>
      Output a yellow colored console warning.<br />
      Example: <code>PM.logger.warn("This is a warning")</code>
    </td>
  </tr>
  <tr>
    <td>debug(message)</td>
    <td>
      Output a purple colored console debug message.<br />
      Example: <code>PM.logger.debug(@some_var)</code>
    </td>
  </tr>
  <tr>
    <td>info(message)</td>
    <td>
      Output a green colored console info message.<br />
      Example: <code>PM.logger.info("This is an info message")</code>
    </td>
  </tr>
</table>

## Console [deprecated]

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>log(log, with_color:color)<br />
        [DEPRECATED] -- use Logger
      </td>
    <td>
      Class method to output a colored console message.<br />
      Example: <code>ProMotion::Console.log("This is red!", with_color: ProMotion::Console::RED_COLOR)</code>
    </td>
  </tr>
</table>

# Help

If you need help, feel free to ping me on twitter @jamonholmgren or open a ticket on GitHub.
Opening a ticket is usually the best and we respond to those pretty quickly.

# Contributing

I'm very open to ideas. Tweet me with your ideas or open a ticket (I don't mind!)
and let's discuss.

## Working on Features

1. Clone the repos into `Your-Project/Vendor/ProMotion`
2. Update your `Gemfile`to reference the project as `gem 'ProMotion', :path => "vendor/ProMotion/"`
3. Run `bundle`
4. Run `rake clean` and then `rake`
5. Contribute!

## Submitting a Pull Request

1. Fork the project
2. Create a feature branch
3. Code
4. Update or create new specs
5. Make sure tests are passing by running `rake spec`
6. Submit pull request
7. Fame, adoration, kudos everywhere

## Primary Contributors

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* Matt Brewer: [@macfanatic](https://twitter.com/macfanatic)


