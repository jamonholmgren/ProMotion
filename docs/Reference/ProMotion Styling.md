PM::Styling is automatically included in many of the objects in ProMotion, such as `PM::Screen`, `PM::TableScreen`, and `PM::Delegate`. It gives you a simple way to apply a hash of attributes and values to a view (or any object that has setters, actually).

PM::Styling is *not* meant to be a full featured styling system. For that, you should use MotionKit or RMQ or some other styling system. This is just for simple applications.

### Contents

* [Usage](#usage)
* [Methods](#methods)
* [Class Methods](#class-methods)
* [Accessors](#accessors)

### Usage

```ruby
class MyScreen < PM::Screen
  def on_load
    set_attributes self.view, {
      background_color: hex_color("#FB3259")
    }
    add UILabel.new, {
      text: "My text",
      frame: [[ 50, 150 ], [ 200, 50 ]],
      background_color: rgba_color(32, 32, 32, 0.5)
    }
    add UIButton.new, {
      frame: [[ 50, 250 ], [ 200, 50 ]],
      "setTitle:forState:" => [ "My title", UIControlStateNormal ]
    }
  end
end
```

### Methods

#### add(view, attrs = {})

Adds the view to the screen after applying the attributes. Attributes are converted to camel case if necessary. `attrs` is usually either a hash, method call that returns a hash, or the name of a method call (in the form of a `:symbol`) that returns the hash.

```ruby
add UIInputView.new, {
  background_color: UIColor.grayColor,
  accessibility_label: "My input view",
  frame: CGRectMake(10, 10, 300, 40)
}

# or use a symbol which calls a method
def my_input_style
  {
    background_color: UIColor.grayColor,
    accessibility_label: "My input view",
    frame: [[10, 10], [300, 40]],
  }
end

add UIInputView.new, :my_input_style # will call my_input_style to get the hash
```

#### remove(view)

Removes the view from the superview.

```ruby
@input = UITextInput.new
add @input
remove @input
```

#### hex_color(str)

Creates a UIColor from a hex string. The # is optional.

```ruby
hex_color("#75D155") # => UIColor instance
```

#### rgb_color(r, g, b)

Creates a UIColor from red, green, and blue levels.

```ruby
rgb_color(23, 54, 21)
```

#### rgba_color(r, g, b, a)

Creates a UIColor with alpha setting from red, green, blue, and alpha levels.

```ruby
rgba_color(23, 54, 21, 0.25)
```

#### content_height(view)

Returns the height necessary to contain all of the visible subviews for `view`.

```ruby
add UILabel.new, { frame: [[ 0, 0 ], [ 150, 100 ]]
content_height(self.view) # => 100
```

#### content_width(view) - `edge`

Returns the width necessary to contain all of the visible subviews for `view`.

```ruby
add UILabel.new, { frame: [[ 0, 0 ], [ 150, 100 ]]
content_width(self.view) # => 150
```

### Class Methods

*None for this module*

### Accessors

*None for this module*