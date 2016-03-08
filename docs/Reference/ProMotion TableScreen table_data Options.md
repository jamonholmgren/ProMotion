<strong>Customizing:</strong> if you're getting crazy deep into styling your table cells,
you really should be subclassing them and specifying that new class in <code>:cell_class</code>. But, if you *really* want to know what ProMotion can do, here's an example format using nearly all available options:

```ruby
def table_data
  [{
    # Section title
    title: "Group Header",
    # Custom UIView suclass for a section header.
    # If your class responds to `title=`, it will be called automatically
    # with the content from the `title:` option above.
    title_view: MyCustomSectionHeader,
    # You can manually set the section title view height. If your class responds
    # to `height`, it will be called automatically and that will be the height.
    # If you specify it here, this number takes precedence.
    title_view_height: 50,

    # Section footer
    footer: "Group Footer",
    # Custom UIView suclass for a section header.
    # If your class responds to `title=`, it will be called automatically
    # with the content from the `footer:` option above.
    footer_view: MyCustomSectionFooter,
    # You can manually set the section footer view height. If your class responds
    # to `height`, it will be called automatically and that will be the height.
    # If you specify it here, this number takes precedence.
    footer_view_height: 50,

    cells: [
      # See cell options documentation
    ]
  }]
end
```

## Using :title_view

You can specify your own section header view and it will automatically be
sized appropriately if your custom UIView subclass implements the `height` method.

For example (using RMQ):

```ruby
class MyCustomSectionHeader < UIView
  # This will create table section header view with a UILabel
  # with the correct font (defined in application_stylesheet.rb)
  # for section headers.
  #
  # Instructions on how to use:
  #
  # def table_data
  #   [{
  #     title_view: MyCustomSectionHeader,
  #     title: "Whatever string you want"
  #   }]
  # end

  def on_load
    # Apply a style to the view instance
    @v = find(self).apply_style(:table_section_header_view)

    # Create the UILabel and set the data to the text provided
    @title = append(UILabel, :table_section_header_label)
  end

  def title=(t)
    @title.data = t

    # Resize the title frame to fit the text
    @title.style{|st| st.resize_height_to_fit }

    # Resize the view instance height
    @v.style do |st|
      st.frame = {
        h: @title.frame.size.height + 15
      }
    end
  end

  # Return the height of the view
  def height
    self.frame.size.height
  end
end
```

## Using :footer_view

You can specify your own section footer view and it will automatically be
sized appropriately if your custom UIView subclass implements the `height` method.

Note that inside the class, the content of the footer is called `title`. This
is not to be confused with the `title` key that you can pass in the section hash
to set the header content.

For example (using RMQ):

```ruby
class MyCustomSectionFooter < UIView
  # This will create table section footer view with a UILabel
  # with the correct font (defined in application_stylesheet.rb)
  # for section footers.
  #
  # Instructions on how to use:
  #
  # def table_data
  #   [{
  #     footer_view: MyCustomSectionFooter,
  #     footer: "Whatever string you want"
  #   }]
  # end

  def on_load
    # Apply a style to the view instance
    @v = find(self).apply_style(:table_section_footer_view)

    # Create the UILabel and set the data to the text provided
    @title = append(UILabel, :table_section_footer_label)
  end

  def title=(t)
    @title.data = t

    # Resize the title frame to fit the text
    @title.style{|st| st.resize_height_to_fit }

    # Resize the view instance height
    @v.style do |st|
      st.frame = {
        h: @title.frame.size.height + 15
      }
    end
  end

  # Return the height of the view
  def height
    self.frame.size.height
  end
end
```
