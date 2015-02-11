ProMotion 2.0 is mostly backwards-compatible to ProMotion 1.2, but there are a few things to look for in your app when you upgrade. Follow this guide and you shouldn't have any issues.

First, update your Gemfile:

```ruby
gem "ProMotion", "~> 2.0"
```

### PM::MapScreen and PM::PushNotification

If you're using a MapScreen or push notifications in your app, add either or both of these gems to your Gemfile right after ProMotion:

```ruby
gem "ProMotion-map"
gem "ProMotion-push"
```

If you were using PM::FormotionScreen, you can try using the ProMotion-formotion gem. Some people have had trouble with this third party gem, so if you have difficulty, feel free to open an issue there (I watch that repo). Another option is to convert over to the new [ProMotion-form](https://github.com/clearsightstudio/ProMotion-form) gem which is much more compatible with ProMotion.

## PM::Screen changes

### Check to make sure your `title`s are only strings

* `title` now only accepts a string. If you want to set an image or view, use `title_image` and `title_view`.

```ruby
class MyScreen < PM::Screen
  title UILabel.new # don't do this
  title UIImage.imageNamed("my-title") # don't do this
  title "String" # good
  title_view UILabel.new # good
  title_image UIImage.imageNamed("my-title") # good
end
```

### Look for `on_create` and change to `on_init`

* Don't use `on_create` anymore. `on_init` is called about the same time that `on_create` used to be.
* Remove any calls to `super` in the new `on_init`.

```ruby
class MyScreen < PM::Screen
  # bad
  def on_create
    # other stuff
    super
  end

  # good
  def on_init
    # other stuff
  end
end
```

### Look for `set_nav_bar_right_button` and `set_nav_bar_left_button`

* Use `set_nav_bar_button :left` and `set_nav_bar_button :right` instead.

```ruby
# Bad
set_nav_bar_right_button "Help", action: :help
# Good
set_nav_bar_button :right, title: "Help", action: :help
```

### Look for any `present_modal_view_controller` calls

* You really shouldn't have been using this undocumented method, and its API has changed. Instead, use `open_modal`.

### Look for any `on_load` methods that set the view

* We've moved `on_load` to fire after the view is created
* If you need to set the root view, do so in the new `load_view` method instead

```ruby
def on_load
  self.view = UIView.new # bad
end

def load_view
  self.view = UIView.new # good
end

def on_load
  self.view.backgroundColor = UIColor.redColor # good
end
```

## PM::TableScreen changes

### In table cells, move arbitrary styling attributes into a `style:` hash

* We now only apply attributes in the `style:` hash to the cell.
* `background_color` is still applied due to some weirdness in UIKit's handling of cell background colors.

```ruby
def table_data
  [{
    cells: [{
      # stays the same
      title: "My title",
      background_color: UIColor.blackColor,

      # bad -- these won't be applied to the cell
      accessibility_label: "My label", 
      background_view: MyBGView.new,

      # good -- these will be applied to the cell
      style: {
        accessibility_label: "My label", 
        background_view: MyBGView.new,        
      }
    }]
  }]
end
```

### Look for any `subviews:` in your table hashes

* We no longer support this feature
* Instead, subclass `PM::TableViewCell` and make your own subviews there

### Look for cell tap actions that rely on the `[:cell]` data being auto-passed in

* We no longer include the `[:cell]` data in the argument hash passed through on tap.
* If you need this info, replicate it in the `arguments:` hash yourself.

```ruby
def table_data
  [{
    cells: [{
      title: "My title",
      action: :some_action,
      arguments: { my_title: "My title" }
    }]
  }]
end

def some_action(args={})
  puts args[:cell][:title] # Bad -- won't work
  puts args[:my_title]     # Good
end
```

## PM::Styling changes

### Look for add_element, add_view, remove_element, remove_view

* These aliases have been removed. Use `add` and `remove` instead.

### Removed easy attributes

* Not too many people knew about these, but there were some `margin:` helpers and whatnot in PM::Styling (`add` and `set_attributes`). These have been removed.
* If your views are not visible or screwed up, you were probably relying on one of these. File an issue and I'll help you migrate.

## Problems?

Get in touch by filing an issue. We'll be there to help you out!

Jamon Holmgren
August 2, 2014



