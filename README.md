# ProMotion

**Please note: this is a proof of concept and does not yet work.**

ProMotion is a new way to organize RubyMotion apps. Instead of dealing
with UIViewControllers and UIViews, you work with Screens. Screens are
a logical way to think of your app.

Typical /app file structure:

    app
      screens
        photos
          list_photos_screen.rb
          show_photo_screen.rb
          edit_photo_screen.rb
        home_screen.rb
        settings_screen.rb
      models
      views
      app_delegate.rb

The "views" folder contains custom view components, written in normal RubyMotion. "models" can be whatever ORM you're using.

### What about MVC?

I'm a big believer in MVC (I'm a Rails developer, too). I found that most of the time working in RubyMotion seems to happen
in the ViewControllers. This pattern may be best for simpler, smaller apps.

This is a proof of concept. I'd really appreciate feedback on it at my email address (jamon@clearsightstudio.com) or Twitter (@jamonholmgren).

## Installation

Add this line to your application's Gemfile:

    gem 'ProMotion'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ProMotion

## Usage

It's easy to load your first screen. Add a navigation bar or just load it bare.

```ruby
# In /app/app_delegate.rb (note that AppDelegate extends ProMotion::AppDelegateParent)
class AppDelegate < ProMotion::AppDelegateParent
  def on_app_load(options)
    home MyHomeScreen.new(nav_bar: true)
  end
end
```

Screens are pretty straightforward. You extend ProMotion::Screen and provide a title and an on_load method.

```ruby
# In /app/screens/home_screen.rb:
class HomeScreen < ProMotion::Screen
  # Set the title for use in nav bars and other containers
  title "Home"

  # Called when this screen is first "opened" and allows you to set up your view components
  def on_load
    @default_image = add_image(:default_image, src: "default.png", frame: [10, 50, 100, 100])
  end
end
```

In on_load, you can add images, buttons, labels, custom views to your screen.

```ruby
# In /app/screens/home_screen.rb:
class HomeScreen < ProMotion::Screen
  # Set the title for use in nav bars and other containers
  title "Home"

  def on_load
    # Add view items as instance vars so you can access them in other methods

    # This adds a right nav bar button. on_tap allows you to set a method to call when it's tapped.
    @right_bar_button = add_right_nav_button(label: "Save", on_tap: :save)

    # Helper function for adding a button
    @settings_button = add_button(label: "Settings", frame: [10, 10, 100, 30])
    
    # Helper function for adding an image
    @default_image = add_image(:default_image, src: "default.png", frame: [10, 50, 100, 100])
    
    # You can also add custom UIViews through the add_view method.
    @custom_view = add_view(ChatView.alloc.initWithFrame(CGRectMake(10, 300, 40, 40)))
  end
end
```

View components can be bound to events (like jQuery) and run methods or run a block.

```ruby
# settings_pushed is executed when the button is tapped
@settings_button = add_button(label: "Settings", frame: [10, 10, 100, 30])
@settings_button.on(:tap, :settings_pushed)

# This demonstrates a block
@settings_button.on(:tap) do
  # Do something
end

# This button passes in arguments to the method when it's tapped
@edit_button = add_button(label: "Edit", frame: [10, 10, 100, 30])
@edit_button.on(:tap, :edit_pushed, id: 4)
```

To open other screens, just call the built-in "open" method on a new instance or class:

```ruby
def settings_button_tapped
  # ...with a class...
  open SettingsScreen

  # ...or with an instance...
  @settings_screen = SettingsScreen.new(some_attr: 4)
  open @settings_screen

  # ...or if you like...
  open SettingsScreen.new
end
```

You can pass in arguments to those screens if they have accessors:

```ruby
# /app/screens/settings_screen.rb
class SettingsScreen < ProMotion::Screen
  attr_accessor :user_type

  def on_load
    if self.user_type == "Admin"
      # Stuff
    end
  end

  # ...
end

# /app/screens/home_screen.rb
class HomeScreen < ProMotion::Screen
  # ...

  def settings_button_tapped
    open SettingsScreen.new(user_type: "Admin")
  end
end
```

When you're done with a screen, just close it:

```ruby
def save_and_close
  if @model.save
    close
  end
end
```

If you want to pass arguments back to the previous screen, go for it.

```ruby
class SettingsScreen < ProMotion::Screen
  # ...

  def save_and_close
    close(saved_changes: true)
  end
end

class MainScreen < ProMotion::Screen
  # ...

  def on_return(args = {})
    if args[:saved_changes]
      self.reload_something
    end
  end
end
```

If you have a custom view controller you want to use on a particular screen, just set it like this:

```ruby
def on_load
  view_controller = MyCustomViewController
end
```

You can create sectioned table screens easily.

```ruby
class HomeScreen < ProMotion::Screen
  title "Home"

  # Defaults to :normal. :plain_table, :grouped_table are options.
  screen_type :grouped_table

  def on_load
    # No need to set anything up, really
  end

  # If you define your screen_type as some sort of table, this gets called to get the data. 
  # You can also refresh the table data manually by calling `self.reload_table_data`
  def table_data
    # You can create a new table section here and add cells to it like so:
    @account_section = add_section(label: "Your Account")
    @account_section.add_cell(title: "Edit Profile", action: :edit_profile, arguments: { account_id: @account.id })
    @account_section.add_cell(title: "Log Out", action: :log_out)

    # Or just pass back an array with everything defined and we'll build it for you:
    [{
      title: "Your Account",
      cells: [
        { title: "Edit Profile", action: :edit_profile },
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
end
```

Here's a full demo of a screen:

```ruby
# In /app/screens/home_screen.rb:

class HomeScreen < ProMotion::Screen
  # Accessors allow screens to set parameters when opening this screen
  attr_accessor :foo

  # Set the title for use in nav bars and other containers
  title "Home"

  # Defaults to :normal. :plain_table, :grouped_table are options.
  screen_type :plain_table

  # Called when this screen is first "opened" and allows you to set up your view components
  def on_load
    # Add view items as instance vars so you can access them in other methods
    # This adds a right nav bar button. on_tap allows you to set a method to call when it's tapped.
    @right_bar_button = add_right_nav_button(label: "Save", on_tap: :save)

    # Helper function for adding a button
    @settings_button = add_button(label: "Settings", frame: [10, 10, 100, 30])
    
    # View items can be bound to events (like jQuery) and run methods or run a block.
    @settings_button.on(:tap, :settings_pushed)
    @settings_button.on(:tapHold) do
      # Do something
    end
    
    # Helper function for adding an image
    @default_image = add_image(:default_image, src: "default.png", frame: [10, 50, 100, 100])
    
    # This button passes in arguments to the method when it's tapped
    @edit_button = add_button(label: "Edit", frame: [10, 10, 100, 30])
    @edit_button.on(:tap, :edit_pushed, id: 4)

    # You can also add custom UIViews through the add_view method.
    @custom_view = add_view(ChatView.alloc.initWithFrame(CGRectMake(10, 300, 40, 40)))
  end

  # If you define your screen_type as some sort of table, this gets called to get the data. 
  # You can also refresh the table data manually by calling `self.reload_table_data`
  def table_data
    # You can create a new table section here and add cells to it like so:
    @account_section = add_section(label: "Your Account")
    @account_section.add_cell(title: "Edit Profile", action: :edit_profile, arguments: { account_id: @account.id })
    @account_section.add_cell(title: "Log Out", action: :log_out)

    # Or just pass back an array with everything defined and we'll build it for you:
    [{
      title: "Your Account",
      cells: [
        { title: "Edit Profile", action: :edit_profile },
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

  # Custom method, invoked when tapping something with this as the action
  def save
    # Assuming some sort of ORM, like ParseModel
    @my_model.save
    
    # When you want to close the current screen (usually in a navigation controller), just run this.
    close

    # You can also pass back arguments to the previous screen as you close.
    # If the previous screen has an `on_return` method, this will be passed into that method
    close(did_stuff: true)
  end

  # This is called any time a screen "above" this screen is closed. args = {} is required.
  def on_return(args = {})
    if args[:did_stuff]
      # Refresh?
    end
  end

  # Custom method
  def settings_pushed
    # Just open a settings screen
    open SettingsScreen

    # If you prefer to pass in an instance, that works too:
    open SettingsScreen.new
  end

  def close_pushed
    close
  end

  # Custom method with passed in arguments
  def edit_pushed(args)
    # Open a screen and set some of its attributes
    open EditScreen.new(id: args[:id])
  end
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
