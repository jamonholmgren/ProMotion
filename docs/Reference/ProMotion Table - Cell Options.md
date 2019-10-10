<strong>Customizing:</strong> if you're getting crazy deep into styling your table cells,
you really should be subclassing them and specifying that new class in <code>:cell_class</code>. But, if you *really* want to know what ProMotion can do, here's an example format using nearly all available options:

```ruby
def table_data
  [{
    title: "Group Header",
    title_view: MyCustomSectionHeader,
    title_view_height: 50,
    footer: "Group Footer",
    footer_view: MyCustomSectionFooter,
    footer_view_height: 50,
    cells: [{
      # Title
      title: "Full featured cell",
      subtitle: "This is my subtitle",

      # Search: you can specify additional search terms
      search_text: "Will match title and these words too!",

      # Tap action, passed arguments
      action: :tapped_cell_1,
      long_press_action: :long_pressed_cell_1, # requires `longpressable`
      arguments: { data: [ "lots", "of", "data" ] },

      # The UITableViewCell
      cell_style: UITableViewCellStyleSubtitle,
      cell_identifier: "my-custom-cell-id", # ProMotion sets this for you intelligently
      cell_class: PM::TableViewCell,
      selection_style: UITableViewCellSelectionStyleNone, # or: :none, :blue, :gray, :default. Note that in iOS7, :blue is no longer blue.

      # View attributes.
      height: 50, # manually changes the cell's height

      # Cell properties. You can add any writeable properties you want in here and they'll
      # be applied to the cell instance with `set_attributes`.
      # Alias is `style:` (but this is discouraged and could be deprecated at some point)
      properties: { # (Edge change, use `style:` in ProMotion 2.0.x)
        masks_to_bounds: true,
        background_color: UIColor.whiteColor, # Creates a UIView for the backgroundView
      },

      # Accessory views (new in 1.0)
      accessory: {
        view: :switch, # UIView or :switch
        value: true, # whether it's "checked" or not
        action: :accessory_switched,
        arguments: { some_arg: true } # :value is passed in if a hash
      },

      # Accessory Type
      # Sets the UITableViewCell's accessoryType property
      # Accepts UITableViewCellAccessory or any of the following symbols:
      # :none, :disclosure_indicator, :disclosure_button, :checkmark, :detail_button
      accessory_type: :none,

      # Swipe-to-delete
      editing_style: :delete, # (can be :delete, :insert, or :none)

      # Moveable Cell
      moveable: true # can also be false or :section

      # Selection
      keep_selection: true, # specifies whether the cell automatically deselects after touch or not

      # Images
      image: {
        image: "something", # PM will do `UIImage.imageNamed("something")` for you
        radius: 15 # radius is optional
      },
      # You can also specify an image with just a UIImage or a String
      # image: UIImage.imageNamed("something"),
      # image: "something",

      # Remote images require the SDWebImage CocoaPod. Make sure the pods section of your Rakefile includes this CocoaPod.
      # For best results, your placeholder image and your remote image should be the same size.
      # The standard UITableViewCell is not designed to work well with images of different sizes.
      remote_image: {
        url: "http://placekitten.com/200/300",
        placeholder: "some-local-image", # NOTE: this is required!
        size: 50,
        radius: 15,
        content_mode: :scale_aspect_fill
      }
    }]
  }]
end
```
