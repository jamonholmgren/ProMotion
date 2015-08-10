<strong>Customizing:</strong> if you're getting crazy deep into styling your table cells,
you really should be subclassing them and specifying that new class in <code>:cell_class</code>. But, if you *really* want to know what ProMotion can do, here's an example format using nearly all available options:

```ruby
def table_data
  [{
    # Section title
    title: "Group Title",
    # Custom UIView suclass for a section header.
    # If your class responds to `title=`, it will be called automatically
    # with the content from the `title:` option above.
    title_view: MyCustomSection,
    # You can manually set the section title view height. If your class responds
    # to `height`, it will be called automatically and that will be the height.
    # If you specify it here, this number takes precedence.
    title_view_height: 50,

    cells: [
      # See cell options documentation
    ]
  }]
end
```
