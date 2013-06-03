# ProMotion [![Build Status](https://travis-ci.org/clearsightstudio/ProMotion.png)](https://travis-ci.org/clearsightstudio/ProMotion)

## A new way to easily build RubyMotion apps.

ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.

Featured on the RubyMotion blog: [http://blog.rubymotion.com/post/50523137515/introducing-promotion-a-full-featured-rubymotion](http://blog.rubymotion.com/post/50523137515/introducing-promotion-a-full-featured-rubymotion)

**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [ProMotion ](#promotion-)
  - [A new way to easily build RubyMotion apps.](#a-new-way-to-easily-build-rubymotion-apps)
- [Tutorials](#tutorials)
  - [Screencasts](#screencasts)
  - [Sample Apps](#sample-apps)
  - [Apps Built With ProMotion](#apps-built-with-promotion)
- [Getting Started](#getting-started)
  - [Setup](#setup)
- [What's New?](#whats-new)
  - [Version 0.7](#version-07)
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
- [API Reference](#api-reference)
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

Here's a demo app that is used to test new functionality. You might have to change the Gemfile
source to pull from Github.

[https://github.com/jamonholmgren/promotion-demo](https://github.com/jamonholmgren/promotion-demo)

## Apps Built With ProMotion

[View apps built with ProMotion (feel free to submit yours in a pull request!)](https://github.com/clearsightstudio/ProMotion/blob/master/PROMOTION_APPS.md)

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

Open it in your favorite editor, then go into your Rakefile and modify the top to look like the following:

```ruby
# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require
```


Create a Gemfile and add the following lines:

```ruby
source 'https://rubygems.org'
gem "ProMotion", "~> 0.7.0"
```

Run `bundle install` in Terminal to install ProMotion.

Go into your app/app_delegate.rb file and replace everything with the following:

```ruby
class AppDelegate < PM::Delegate
  def on_load(app, options)
    open HomeScreen.new(nav_bar: true)
  end
end
```

Note: You can use other keys in `on_load` when you open a new screen:

* `modal:  ` [`true` | `false`]
* `toolbar:` [`true` | `false`]

Make sure you remove the `didFinishLoadingWithOptions` method or call `super` in it. Otherwise
ProMotion won't get set up and `on_load` won't be called.

Create a folder in `/app` named `screens`. Create a file in that folder named `home_screen.rb`.

Now drop in this code:

```ruby
class HomeScreen < PM::Screen
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

## Version 0.7

* Added [Teacup](https://github.com/rubymotion/teacup) support! Just specify `stylename:` in your `add:` or `set_attributes:` property hash.
* Added `PM::FormotionScreen` for easy [Formotion](https://github.com/clayallsopp/formotion) compatibility.
* Massive refactor of `PM::TableScreen` to make it more reliable and testable. Deprecated some old stuff in there.
* Made a new `TableViewCellModule` that makes it easy to set up custom cells.
* Refactored the `PM::Delegate` class to make it cleaner and more testable.
* Added `PM::PushNotification` class (this needs more work and testing) and some nice `PM::Delegate` methods for registering and handling them.
* `set_nav_bar_left_button` and `set_nav_bar_right_button` are now just `set_nav_bar_button`. See API reference.
* Speaking of API reference, [we now have one](https://github.com/clearsightstudio/ProMotion/wiki/_pages). We've moved the bulk of the info to the wiki.
* Added `open_modal` alias for `open @screen, modal: true`
* Added functional (interactive) tests and lots of unit tests. Run `rake spec:functional` or `rake spec:unit` to run them individually.
* Renamed `is_modal?` to `modal?`, `has_nav_bar?` to `nav_bar?` in screens.
* Removed MotionTable references.
* Lots of small improvements and bugfixes.

# Usage

## Creating a basic screen

```ruby
class HomeScreen < PM::Screen
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
class AppDelegate < PM::Delegate
  def on_load(app, options)
    open MyHomeScreen.new(nav_bar: true)
  end
end
```

## Creating a split screen (iPad apps only)

```ruby
# In app/app_delegate.rb
class AppDelegate < PM::Delegate
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

This method adds the buttons to the top navigation bar of a screen. The `action:` lets you specify a method to
call when that button is tapped, and you can pass in a UIBarButton style using `type:`.

```ruby
set_nav_bar_button :right, title: "Save", action: :save_something, type: UIBarButtonItemStyleDone
set_nav_bar_button :left, title: "Cancel", action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
```

You can pass in an image with `image:`. *Don't forget retina and landscape versions of your image!*

```ruby
set_nav_bar_button :left, image: UIImage.imageNamed("cancel-button"), action: :cancel_something
```

You can also pass in a `system_icon` instead.

```ruby
set_nav_bar_button :right, system_icon: UIBarButtonSystemItemAdd, action: :add_something
```

Additionally, if you pass an instance of a `UIBarButtonItem`, the `UIBarButton` will automatically display that particular button item.

```ruby
set_nav_bar_button :left, button: UIBarButtonItem.alloc.initWithCustomView(button)
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

# Or... (this is equivalent)

open_modal SettingsScreen.new
```

You can pass in arguments to other screens if they have accessors:

```ruby
class HomeScreen < PM::Screen
  # ...

  def settings_button_tapped
    open ProfileScreen.new(user: some_user)
  end
end

class ProfileScreen < PM::Screen
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
class ItemScreen < PM::Screen
  # ...
  def save_and_close
    if @model.save
      close(model_saved: true)
    end
  end
end

class MainScreen < PM::Screen
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
class MenuScreen < PM::TableScreen
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
`add` accepts a second argument which is a hash of attributes that get applied to the element right after it is
dropped into the view.

`add(view, attr={})`

```ruby
add UILabel.new, {
  text: "This is awesome!",
  font: UIFont.systemFontOfSize(18),
  resize: [ :left, :right, :top, :bottom, :width, :height ], # autoresizingMask
  left: 5, # These four attributes are used with CGRectMake
  top: 5,
  width: 20,
  height: 20
}
```

Using Teacup? Just provide a `stylename`.

```ruby
@element = UIView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20))
add @element, stylename: :my_custom_view
```

The `set_attributes` method is identical to add except that it does not add it to the current view.
If you use snake_case and there isn't an existing method, it'll try camelCase. This allows you to
use snake_case for Objective-C methods.

`set_attributes(view, attr={})`

```ruby
set_attributes UIView.new, {
  # `background_color` is translated to `backgroundColor` automatically.
  background_color: UIColor.whiteColor,
  frame: CGRectMake(0, 0, 20, 20)
}
```

You can use `add_to` to add a view to any other view, not just the main view.

`add_to(parent_view, new_view, attr={})`

```ruby
add_to @some_parent_view, UIView.new, {
  frame: CGRectMake(0, 0, 20, 20),
  backgroundColor: UIColor.whiteColor
}
```

## Table Screens

You can create sectioned table screens easily with TableScreen, SectionedTableScreen, and GroupedTableScreen.

```ruby
class SettingsScreen < PM::GroupedTableScreen
  title "Settings"

  def on_load
    set_nav_bar_right_button("Save", action: :save)
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

## Using your own UIViewController

### [Usage: Formotion or other custom UIViewControllers](https://github.com/clearsightstudio/ProMotion/wiki/Usage:-Formotion-or-other-custom-UIViewControllers)

# API Reference

We've created a fairly comprehensive wiki with code examples, usage examples, and API reference.

### [ProMotion API Reference](https://github.com/clearsightstudio/ProMotion/wiki/_pages)

# Help

If you need help, feel free to ping me on twitter [@jamonholmgren](http://twitter.com/jamonholmgren)
or open an issue on GitHub. Opening an issue is usually the best and we respond to those pretty quickly.

# Contributing

I'm very open to ideas. Tweet me with your ideas or open a ticket (I don't mind!)
and let's discuss. **It's a good idea to run your idea by the committers before creating
a pull request.** We'll always consider your ideas carefully but not all ideas will be
incorporated.

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
4. Update or create new specs ** NOTE: your PR is far more likely to be merged if you include comprehensive tests! **
5. Make sure tests are passing by running `rake spec` *(you can run functional and unit specs separately with `rake spec:functional` and `rake spec:unit`)*
6. Submit pull request
7. Make a million little nitpicky changes that @jamonholmgren wants
8. Merged, then fame, adoration, kudos everywhere

## Primary Contributors

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* Matt Brewer: [@macfanatic](https://twitter.com/macfanatic)
* [Many others](https://github.com/clearsightstudio/ProMotion/graphs/contributors)

