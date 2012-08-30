# ProMotion

**Please note: this is a proof of concept and does not yet work.**

ProMotion is a new way to organize RubyMotion apps. Instead of dealing
with UIViewControllers and UIViews, you work with Screens. Screens are
a logical way to think of your app.

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
    @window = HomeScreen.open_in_navigation

    true
  end
end

# In /app/screens/home_screen.rb:

class HomeScreen < ProMotion::Screen
  attr_accessor :id

  title "Home"
  screenType :plain_table

  def on_load
    @right_bar_button = add_right_nav_button(label: "Save", on_tap: :save)

    @settings_button = add_button(label: "Settings", frame: [10, 10, 100, 30])
    @settings_button.on(:tap, :settings_pushed)
    @settings_button.on(:tapHold, :settings_held)
    
    @default_image = add_image(:default_image, src: "default.png", frame: [10, 50, 100, 100])
    
    @edit_button = add_button(label: "Edit", frame: [10, 10, 100, 30])
    @edit_button.on(:tap, :edit_pushed, id: 4)

    @custom_view = add_view(ChatView.alloc.initWithFrame(CGRectMake(10, 300, 40, 40)))
  end

  def table_data
    # You can create a new table section here and add cells to it
    @account_section = addSection(label: "Your Account")
    @account_section.addCell(title: "Edit Profile", action: :edit_profile, arguments: { account_id: @account.id })
    @account_section.addCell(title: "Log Out", action: :log_out)

    # Or just pass back an array with everything defined and we'll build it for you
    [{
      title: "Your Account",
      cells: [
        { title: "Edit Profile", action: :editProfile },
        { title: "Log Out", action: :logOut },
        { title: "Find Friends", action: :findFriends },
        { title: "Sharing Settings", action: :sharingSettings },
        { title: "Notification Settings", action: :notificationSettings }
      ]
    }, {
      title: "App Stuff",
      cells: [
        { title: "About", action: :showAbout },
        { title: "Feedback", action: :showFeedback }
      ]
    }]
  end

  def save
    @my_model.save
    self.close
  end

  def settings_pushed
    SettingsScreen.open
  end

  def settings_held
    @default_image.animate_to([10, 150, 100, 100])
  end

  def close_pushed
    self.close
  end

  def edit_pushed(args)
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
