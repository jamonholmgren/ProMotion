# ProMotion - A new way to organize RubyMotion apps.

ProMotion introduces a new object called "Screens". Screens have a one-to-one relationship 
with your app's screens and can (usually) take the place of view controllers.

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
      view_controllers
      views
      app_delegate.rb

## Usage

Loading your home screen:

```ruby
# In /app/app_delegate.rb (note that AppDelegate extends ProMotion::AppDelegateParent)
class AppDelegate < ProMotion::AppDelegateParent
  def on_load(options)
    open_screen MyHomeScreen.new(nav_bar: true)
  end
end
```

Creating a basic screen:

```ruby
class HomeScreen < ProMotion::Screen
  title "Home"

  def on_load
    # Set up the elements in your view with add_element:
    @label = add_element UILabel.alloc.initWithFrame(CGRectMake(5, 5, 20, 20)), {
      text: "This is awesome!",
      font: UIFont.UIFont.systemFontOfSize(18)
    }
  end
  
  def on_appear
    # Refresh the data if you want
  end
end
```

Creating a tabbed bar:

```ruby
def on_load(options)
  @home = MyHomeScreen.new(nav_bar: true)
  @settings = SettingsScreen.new
  @contact = ContactScreen.new(nav_bar: true)
  open_tab_bar @home, @settings, @contact
end
```

Any view item (UIView, UIButton, etc) can be used with add_element.
The second argument is a hash of settings that get applied to the
element before it is dropped into the view.

```ruby
@label = add_element UILabel.alloc.initWithFrame(CGRectMake(5, 5, 20, 20)), {
  text: "This is awesome!",
  font: UIFont.UIFont.systemFontOfSize(18)
}
```

Add a nav_bar button and a tab_bar icon:

```ruby
add_right_nav_button(label: "Save", action: :save)
set_tab_bar_item(title: "Contacts", system_icon: UITabBarSystemItemContacts)
```

Open a new screen:

```ruby
def settings_button_tapped
  # ...with a class...
  open_screen SettingsScreen

  # ...or with an instance...
  @settings_screen = SettingsScreen.new
  open_screen @settings_screen
end
```

You can pass in arguments to other screens if they have accessors:

```ruby
class HomeScreen < ProMotion::Screen
  # ...

  def settings_button_tapped
    open_screen ProfileScreen.new(user: some_user)
  end
end

class ProfileScreen < ProMotion::Screen
  attr_accessor :user

  def on_load
    self.user # => some_user instance
  end
end

```

Close a screen, passing back arguments to the previous screen's "on_return" method:

```ruby
class ItemScreen
  # ...
  def save_and_close
    if @model.save
      close_screen(model_saved: true)
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

Use a custom view controller:

```ruby
def on_load
  set_view_controller MyCustomViewController
  
  # Note: on_appear will not fire when using a custom 
  # view controller.
end
```

The helper add_element takes a

You can create sectioned table screens easily. TableScreen, SectionedTableScreen, GroupedTableScreen

```ruby
class SettingsScreen < ProMotion::GroupedTableScreen
  title "Settings"

  def on_load
    add_right_nav_button(label: "Save", action: :save)
    set_tab_bar_item(title: "Settings", icon: "settings.png")
  end
  
  # table_data is automatically called. Use this format in the return value.
  # Grouped tables are the same as plain tables
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
    return ["A", "B", "C"]
  end
  
  # Your table cells, when tapped, will execute the corresponding actions and pass in arguments:
  def edit_profile(arguments)
    # ...
  end
end
```

### What about MVC?

I'm a big believer in MVC (I'm a Rails developer, too). I found that most of the time working in RubyMotion seems to happen
in the ViewControllers and views are mainly custom elements. This pattern may be best for simpler, smaller apps.

Feedback welcome via twitter @jamonholmgren.

## Contributing

I'm really looking for feedback. Tweet me with your ideas or open a ticket (I don't mind!) and let's discuss.
