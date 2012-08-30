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



```ruby
# In /app/app_delegate.rb:

class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = HomeScreen.open_with_nav_bar

    true
  end
end

# In /app/screens/home_screen.rb:

class HomeScreen < ProMotion::Screen
  # Accessors allow screens to set parameters when opening this screen
  attr_accessor :foo

  # Set the title for use in nav bars and other containers
  title "Home"

  # Defaults to :normal. :plain_table, :grouped_table are options.
  screen_type :plain_table

  # Called when this view is first "opened" and allows you to set up your view
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
    
    # When you want to close the current view (usually in a navigation controller), just run this.
    self.close

    # You can also pass back arguments to the previous view as you close.
    # If the previous screen has an `on_return` method, this will be passed into that method
    self.close(did_stuff: true)
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
    SettingsScreen.open
  end

  def close_pushed
    self.close
  end

  # Custom method with passed in arguments
  def edit_pushed(args)
    # Open a screen and set some of its attributes
    EditScreen.open(id: args[:id])
  end
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
