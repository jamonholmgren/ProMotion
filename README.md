# ProMotion - A new way to easily build RubyMotion apps.

ProMotion introduces a new object called "Screens". Screens have a one-to-one relationship 
with your app's designed screens.

Check out the tutorial here: http://www.clearsightstudio.com/insights/ruby-motion-promotion-tutorial

Sample app here: https://github.com/jamonholmgren/promotion-tutorial

Typical app file structure:

    app/
      screens/
        photos/
          list_photos_screen.rb
          show_photo_screen.rb
          edit_photo_screen.rb
        home_screen.rb
        settings_screen.rb
      models/
      views/
      app_delegate.rb

## Usage

Loading your home screen:

```ruby
# In /app/app_delegate.rb
class AppDelegate < ProMotion::AppDelegate
  def on_load(app, options)
    open MyHomeScreen.new(nav_bar: true)
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
      font: UIFont.systemFontOfSize(18)
    }
  end
  
  def on_appear
    # Refresh the data if you want
  end
end
```

Creating a tabbed bar with multiple screens. This will set the tab bar as the root view controller for your app,
so keep that in mind. It can be done from the AppDelegate#on_load or from a screen.

### Creating a tab bar with several screens

```ruby
def on_load(app, options)
  @home     = MyHomeScreen.new(nav_bar: true)
  @settings = SettingsScreen.new
  @contact  = ContactScreen.new(nav_bar: true)
  @tab_bar  = open_tab_bar @home, @settings, @contact
end
```

For each screen that belongs to the tab bar, you need to set the tab name and icon in the files. 
In this example, we would need add the following to the three files (my_home_screen.rb, settings_screen.rb, contact_screen.rb):

```ruby
def on_load
  set_tab_bar_item title: "Tab Name Goes Here", icon: "icons/tab_icon.png" # in resources/icons folder
  
  # or...
  set_tab_bar_item title: "Contacts", system_icon: UITabBarSystemItemContacts
end
```

### Adding view elements

Any view item (UIView, UIButton, custom UIView subclasses, etc) can be used with add_element.
The second argument is a hash of settings that get applied to the
element before it is dropped into the view.

```ruby
@label = add_element UILabel.alloc.initWithFrame(CGRectMake(5, 5, 20, 20)), {
  text: "This is awesome!",
  font: UIFont.systemFontOfSize(18)
}
```

Add nav_bar buttons:

```ruby
set_nav_bar_right_button "Save", action: :save_something, type: UIBarButtonItemStyleDone
set_nav_bar_left_button "Cancel", action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
```

Open a new screen:

```ruby
def settings_button_tapped
  # ...with a class...
  open SettingsScreen

  # ...or with an instance...
  @settings_screen = SettingsScreen.new
  open @settings_screen
end
```

Open a new screen as a modal:

```ruby
open SettingsScreen, modal: true
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

Close a screen (modal or in a nav controller), passing back arguments to the previous screen's "on_return" method:

```ruby
class ItemScreen
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

Use a custom view controller:

```ruby
def on_load
  set_view_controller MyCustomViewController
  
  # Note: on_appear will not fire when using a custom 
  # view controller.
end
```

The helper add_element takes any view object and adds it to the current view. You can also use
the helper ProMotion::ViewHelper.set_attributes(view, attributes) to do the same thing without adding
it to the current view. Screens include this helper by default.

```ruby
@element = add_element UIView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20)), {
  backgroundColor: UIColor.whiteColor
}

@element = set_attributes UIView.alloc.initWithFrame(CGRectMake(0, 0, 20, 20)), {
  backgroundColor: UIColor.whiteColor
}
```

You can create sectioned table screens easily. TableScreen, SectionedTableScreen, GroupedTableScreen.
This is loosely based on [motion-table](https://github.com/clearsightstudio/motion-table) (there are a 
few minor differences). We will eventually combine the two.

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

# Reference
(not comprehensive yet...working on this)

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

### What about MVC?

I'm a big believer in MVC (I'm a Rails developer, too). I found that most of the time working in RubyMotion seems to happen
in the ViewControllers and views are mainly custom elements. This pattern is probably best for navigation controller and
tab bar based apps.

Feedback welcome via twitter @jamonholmgren or email jamon@clearsightstudio.com.

## Contributing

I'm really looking for feedback. Tweet me with your ideas or open a ticket (I don't mind!) and let's discuss.
