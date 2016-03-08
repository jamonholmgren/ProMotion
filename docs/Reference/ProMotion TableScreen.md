### Contents

* [Usage](#usage)
* [Methods](#methods)
* [Class Methods](#class-methods)
* [Accessors](#accessors)

### Usage

ProMotion::TableScreen allows you to easily create lists or "tables" as iOS calls them. It's a subclass of [UITableViewController](http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableViewController_Class/Reference/Reference.html) and has all the goodness of [PM::Screen](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::Screen) with some additional magic to make the tables work beautifully.

|Table Screens|Grouped Tables|Searchable|Refreshable|
|---|---|---|---|
|![ProMotion TableScreen](https://f.cloud.github.com/assets/1479215/1534137/ed71e864-4c90-11e3-98aa-ed96049f5407.png)|![Grouped Table Screen](https://f.cloud.github.com/assets/1479215/1589973/61a48610-5281-11e3-85ac-abee99bf73ad.png)|![Searchable](https://f.cloud.github.com/assets/1479215/1534299/20cc05c6-4c93-11e3-92ca-9ee39c044457.png)|![Refreshable](https://f.cloud.github.com/assets/1479215/1534317/5a14ef28-4c93-11e3-8e9e-f8c08d8464f8.png)|

```ruby
class TasksScreen < PM::TableScreen
  title "Tasks"
  refreshable
  searchable placeholder: "Search tasks", no_results: "Sorry, Try Again!"
  row_height :auto, estimated: 44

  def on_load
    @tasks = []
    load_async
  end

  def table_data
    [{
      cells: @tasks.map do |task|
        {
          title: task.title,
          subtitle: task.description,
          action: :edit_task,
          arguments: { task: task }
        }
      end
    }]
  end

  def on_refresh
    load_async
  end

  def load_async
    # Assuming we're loading tasks from some cloud service
    Task.async_load do |tasks|
      @tasks = tasks
      stop_refreshing
      update_table_data
    end
  end
end
```

Example of a `PM::GroupedTableScreen`: https://gist.github.com/jamonholmgren/382a6cf9963c5f0b2248

### Methods

#### table_data

Method that is called to get the table's cell data and build the table.

It consists of an array of cell sections, each of which contain an array of cells.

```ruby
def table_data
  [{
    title: "Northwest States",
    cells: [
      { title: "Oregon", action: :visit_state, arguments: { state: @oregon }},
      { title: "Washington", action: :visit_state, arguments: { state: @washington }}
    ]
  }]
end
```

You'll often be iterating through a group of objects. You can use `.map` to easily build your table:

```ruby
def table_data
  [{
    title: "States",
    cells:
      State.all.map do |state|
        {
          title: state.name,
          action: :visit_state,
          arguments: { state: state }
        }
      end
  }]
end

def visit_state(args={})
  mp args[:state] # => instance of State
end
```

View the [Reference: All available table_data options](ProMotion TableScreen table_data Options.md) for an example with all available options.

#### Accessory Views

`TableScreen` supports the `:switch` accessory and custom accessory views.

![accessory](http://clrsight.co/jh/accessory.png)

Using Switches:

```ruby
{
  title: "Switch With Action",
  accessory: {
    view: :switch,
    value: true, # switched on
    action: :foo
  }
}, {
  title: "Switch with Action and Parameters",
  accessory: {
   view: :switch,
   action: :foo,
   arguments: { bar: 12 }
 }
}, {
  title: "Switch with Cell Tap, Switch Action and Parameters",
  accessory: {
    view: :switch,
    action: :foo,
    arguments: { bar: 3 },
  },
  action: :fizz,
  arguments: { buzz: 10 }
}
```

Using a custom `accessory` view:

```ruby
    button1 = set_attributes UIButton.buttonWithType(UIButtonTypeRoundedRect), {
      "setTitle:forState:" => [ "A", UIControlStateNormal ]
    }
    button2 = set_attributes UIButton.buttonWithType(UIButtonTypeRoundedRect), {
      "setTitle:forState:" => [ "B", UIControlStateNormal ]
    }
    button1.frame = [[ 0, 0 ], [ 20, 20 ]]
    button2.frame = [[ 0, 0 ], [ 20, 20 ]]
    [{
      title: "",
      cells: [{
        title: "My Cell with custom button",
        accessory: { view: button1 }
      }, {
        title: "My Second Cell with another custom button",
        accessory: { view: button2 }
      }]
    }]
```

*However*, adding custom accessory views like this is not recommended unless your use case is very simple. Instead, subclass `PM::TableViewCell` and provide setters that create the subviews or accessoryView that you want. You can find a blog post demonstrating how this is done here: http://jamonholmgren.com/creating-a-custom-uitableviewcell-with-promotion

#### update_table_data

Causes the table data to be refreshed, such as when a remote data source has
been downloaded and processed.

```ruby
class MyTableScreen < PM::TableScreen

  def on_load
    MyItem.pull_from_server do |items|
      @table_data = [{
        cells: items.map do |item|
          {
            title: item.name,
            action: :tapped_item,
            arguments: { item: item }
          }
        end
      }]

      update_table_data
    end
  end

  def table_data
    @table_data ||= []
  end

  def tapped_item(item)
    open ItemDetailScreen.new(item: item)
  end

end
```

#### table_data_index

This method allows you to create a "jumplist", the index on the right side of the table

A good way to do this is to grab the first letter of the title of each section:

```ruby
def table_data_index
  # Returns an array of the first letter of the title of each section.
  table_data.collect{ |section| (section[:title] || " ")[0] }
end
```

#### on_cell_created(cell, data)

Called when a cell is created (not dequeued).  `data` is the cell hash you provided in the `table_data` method.

It's recommended that you call `super` if you override this method.

```ruby
def on_cell_created(cell, data)
  super
  cell.my_cool_method(data[:properties][:my_property])
  cell.contentView.backgroundColor = UIColor.purpleColor
end
```

#### on_cell_reused(cell, data)

Called when a cell is dequeued and re-used. `data` is the cell hash you provided in the `table_data` method.

It's recommended that you call `super` if you override this method.

```ruby
def on_cell_reused(cell, data)
  super
  cell.my_cool_method(data[:properties][:my_property])
  cell.contentView.backgroundColor = UIColor.purpleColor
end
```

#### will_display_cell(cell, index_path)

Fires right before a cell is displayed in a table. Use this method to do additional setup on the cell, or other operations such as infinite scroll.

```ruby
def will_display_cell(cell, index_path)
  cell.backgroundColor = UIColor.clearColor
  if index_path.row >= @data.length
    load_more_data   # infinite scroll
  end
end
```

#### on_cell_deleted(cell, index_path)

If you specify `editing_style: :delete` in your cell, you can swipe to reveal a delete button on that cell. When you tap the button, the cell will be removed in an animated fashion and the cell will be removed from its respective `table_data` section.

If you need a callback for every cell that's deleted, you can implement the `on_cell_deleted(cell)` method, where `cell` is the attributes form the original cell data object. Returning `false` will cancel the delete action. Anything else will allow it to proceed.

Example:

```ruby
def on_cell_deleted(cell, index_path)
  if cell[:arguments][:some_value] == "something"
    App.alert "Sorry, can't delete that row." # BubbleWrap alert
    false
  else
    RemoteObject.find(cell[:arguments][:id]).delete_remotely
    true # return anything *but* false to allow deletion in the UI
  end
end
```

#### delete_row(indexpath, animation=nil)

You can call `delete_row(indexpath, animation)` to delete. Both the UI and the internal
data hash are updated when you do this.

```ruby
def my_delete_method(section, row)
  # the 2nd argument is optional. Defaults to :automatic
  delete_row(NSIndexPath.indexPathForRow(row, inSection:section), :fade)
end
```

#### table_header_view

You can give the table a custom header view (this is different from a section header view, which is below) by defining:

```ruby
def table_header_view
  # Return a UIView subclass here and it will be set at the top of the table.
end
```

This is useful for information that needs to only be at the very top of a table.

#### will_display_header(view)

You can customize the section header views just before they are displayed on the table. This is different from table header view, which is above.

```ruby
def will_display_header(view)
  view.tintColor = UIColor.redColor
  view.textLabel.setTextColor(UIColor.blueColor)
end
```

#### table_footer_view

You can give the table a custom footer view (this is different from a section footer view) by defining:

```ruby
def table_footer_view
  # Return a UIView subclass here and it will be set at the bottom of the table.
end
```

This is useful for information that needs to only be at the very bottom of a table.

---

### Class Methods

#### searchable(placeholder: "placeholder text", no_results: "some short qiup here", with: -> (cell, search_string){})

Class method to make the current table searchable.

```ruby
class MyTableScreen < PM::TableScreen
  searchable placeholder: "Search This Table"
end
```

Specifying `no_results:` will change the text that is displayed when there are
no results found.

```ruby
class MyTableScreen < PM::TableScreen
  searchable placeholder: "Search This Table", no_results: "BZZZZZ! Try Again!"
end
```

Without a `with:` specifier, search is performed on the `title` attribute, and
the `search_text` attribute, if present. If you want to create a custom search
method, specify it as the value of the `with` key (`find_by`, `search_by` and `filter_by`
are aliases). E.g.:

```ruby
class MyTableScreen < PM::TableScreen
  searchable placeholder: "Search This Table", with: -> (cell, search_string){
    cell[:properties][:some_obscure_attribute].strip.downcase.include? search_string.strip.downcase
  }
end
```

or if you want to create a version that is less resistant to refactoring:

```ruby
class MyTableScreen < PM::TableScreen
  searchable placeholder: "Search This Table", with: :custom_search_method

  def custom_search_method(cell, search_string)
    cell[:properties][:some_obscure_attribute].strip.downcase.include? search_string.strip.downcase
  end
end
```

![Searchable Image](http://clrsight.co/jh/Screen_Shot_2014-06-21_at_9.01.09_PM.png)

To initially hide the search bar behind the nav bar until the user scrolls it into view, use `hide_initially`.

```ruby
class MyTableScreen < PM::TableScreen
  searchable hide_initially: true
end
```

You can prevent any table cell from being included in search results by setting the cell attribute `searchable` to `false` like this:

```ruby
[{
  title: "This cell will appear in the search",
},{
  title: "This cell will not",
  searchable: false
}]
```

You can supply additional textual data that you want to be searchable but not display anywhere on the cell by setting the cell attribute `search_text` to a string. Cells with `search_text` will display in search results if the search term matches either the `title` *or* the `search_text` attributes.

```ruby
[{
  title: "Searchable via Title"
},{
  title: "Searchable via Title",
  search_text: "and will match these words too!"
}]
```

If you need to know if the current table screen is being searched, `searching?` will return `true` if the user has entered into the search bar (even if there is no search results yet).

To get the text that a user has entered into the search bar, you can call `search_string` for what the data was actually searched against and `original_search_string` to get the actual text the user entered. These methods will return back a `String` or a falsey object (`nil` or `false`).

You can also implement methods in your `TableScreen` that are called when the search starts or ends:

```ruby
def will_begin_search
  puts "the user tapped the search bar!"
end

def will_end_search
  puts "the user tapped the 'cancel' button!"
end
```

#### row_height(height, options = {})

Class method to set the row height for each UITableViewCell. You can use iOS 8's 'automatic' row height feature by passing `:auto` as the first argument.

```ruby
class MyTableScreen < PM::TableScreen
  row_height :auto, estimated: 44
end
```

#### refreshable(options = {})

Class method to make the current table have pull-to-refresh. All parameters are optional.
If you do not specify a callback, it will assume you've implemented an <code>on_refresh</code>
method in your tableview.

![](https://camo.githubusercontent.com/fa0ac0a77e6170cca72f03f9ad2273c5b165e83d/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f313437393231352f313533343331372f35613134656632382d346339332d313165332d386539652d6638633038643834363466382e706e67)

```ruby
class MyTableScreen < PM::TableScreen

  refreshable callback: :on_refresh,
    pull_message: "Pull to refresh",
    refreshing: "Refreshing data…",
    updated_format: "Last updated at %s",
    updated_time_format: "%l:%M %p"

  def on_refresh
    MyItems.pull_from_server do |items|
      @my_items = items
      end_refreshing
      update_table_data
    end
  end

end
```

If you initiate a refresh event manually by calling `start_refreshing`, the table view will automatically scroll down to reveal the spinner at the top of the table.

#### indexable

This simply takes the first letter of each of your section titles and uses those for the "jumplist" on the right side of your table screen.

```ruby
class MyTable < PM::TableScreen
  indexable

  # ...
end
```

#### longpressable

This will allow you to specify an additional "long_press_action" on your table cells.

```ruby
class MyTable < PM::TableScreen
  longpressable

  def table_data
    [{
      cells: [{
        title: "Long press cell",
        action: :normal_action,
        long_press_action: :long_press_action,
        arguments: { foo: "Will be sent along with either action as arguments" }
      }]
    }]
  end
end
```

---

### Accessors

You get all the normal accessors of `PM::Screen`, but no documented TableScreen accessors are available.

---

### Moveable cells

You can specify cells to be moveable in each individual cell hash. If you want the cells to only be moveable within their own section, define `moveable: :section` in each cell hash.

When you want the user to see the moveable drag handles, call `toggle_edit_mode` or `edit_mode(enabled:true)`.

Finally, define a method:

```ruby
def on_cell_moved(args)
  # Do something here
end
```

The argument passed to `on_cell_moved` is a hash in the form of:

```ruby
{
  :paths   => {
    :from     => #<NSIndexPath:0xb777380>,
    :to       => #<NSIndexPath:0xb777390>
  },
  :cell    => {
    :title        => "Whatever",
    :moveable     => true
    # Your other cell attributes
  }
}
```
