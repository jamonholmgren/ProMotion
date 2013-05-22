
## Screen

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>is_modal?</td>
    <td>Returns if the screen was opened in a modal window.</td>
  </tr>
  <tr>
    <td>self</td>
    <td>Returns the Screen which is a subclass of UIViewController or UITableViewController</td>
  </tr>
  <tr>
    <td>has_nav_bar?</td>
    <td>Returns if the screen is contained in a navigation controller.</td>
  </tr>
  <tr>
    <td>set_tab_bar_item(args)</td>
    <td>
      Creates the tab that is shown in a tab bar item.<br />
      Arguments: <code>{ icon: "imagename", systemIcon: UISystemIconContacts, title: "tabtitle" }</code>
    </td>
  </tr>
  <tr>
    <td>on_appear</td>
    <td>
      Callback for when the screen appears.<br />
    </td>
  </tr>
  <tr>
    <td>will_appear</td>
    <td>
      Callback for before the screen appears.<br />
      This is a good place to put your view constructors, but be careful that
      you don't add things more than on subsequent screen loads.
    </td>
  </tr>
  <tr>
    <td>will_disappear</td>
    <td>
      Callback for before the screen disappears.<br />
    </td>
  </tr>
  <tr>
    <td>will_rotate(orientation, duration)</td>
    <td>
      Callback for before the screen rotates.<br />
    </td>
  </tr>
  <tr>
    <td>on_opened **Deprecated**</td>
    <td>
      Callback when screen is opened via a tab bar. Please don't use this, as it will be removed in the future<br />
      Use will_appear
    </td>
  </tr>
  <tr>
    <td>set_nav_bar_button(side, args = {})</td>
    <td>
      Set a nav bar button.<br />
      `side` can be :left or :right. `args` can include the following:<br />
      title: "Button Title"<br />
      image: (UIImage)<br />
      system_icon: (UIBarButtonSystemItem)<br />
      button: (UIBarButtonItem)<br />
      
    </td>
  </tr>
  <tr>
    <td>should_autorotate</td>
    <td>
      (iOS 6) return true/false if screen should rotate.<br />
      Defaults to true.
    </td>
  </tr>
  <tr>
    <td>should_rotate(orientation)</td>
    <td>
      (iOS 5) Return true/false for rotation to orientation.<br />
    </td>
  </tr>
  <tr>
    <td>title</td>
    <td>
      Returns title of current screen.<br />
    </td>
  </tr>
  <tr>
    <td>title=(title)</td>
    <td>
      Sets title of current screen.<br />
      You can also set the title like this (not in a method, though):<br />
<pre><code>
class SomeScreen
  title "Some screen"

  def on_load
    # ...
  end
end
</code></pre>
    </td>
  </tr>
  <tr>
    <td>add(view, attrs = {})</td>
    <td>
      Adds the view to the screen after applying the attributes.<br />
      (alias: `add_element`, `add_view`)<br />
      Example:
      <code>
        add UIInputView.alloc.initWithFrame(CGRectMake(10, 10, 300, 40)), {
          backgroundColor: UIColor.grayColor
        }
      </code>
    </td>
  </tr>
  <tr>
    <td>remove(view)</td>
    <td>
      Removes the view from the superview and sets it to nil<br />
      (alias: `remove_element`, `remove_view`)
    </td>
  </tr>
  <tr>
    <td>bounds</td>
    <td>
      Accessor for self.view.bounds<br />
    </td>
  </tr>
  <tr>
    <td>frame</td>
    <td>
      Accessor for self.view.frame<br />
    </td>
  </tr>
  <tr>
    <td>view</td>
    <td>
      The main view for this screen.<br />
    </td>
  </tr>
  <tr>
    <td>ios_version</td>
    <td>
      Returns the iOS version that is running on the device<br />
    </td>
  </tr>
  <tr>
    <td>app_delegate</td>
    <td>
      Returns the AppDelegate<br />
    </td>
  </tr>
  <tr>
    <td>close(args = {})</td>
    <td>
      Closes the current screen, passes args back to the previous screen's <code>on_return</code> method<br />
    </td>
  </tr>
  <tr>
    <td>open_root_screen(screen)</td>
    <td>
      Closes all other open screens and opens <code>screen</code> as the root view controller.<br />
    </td>
  </tr>
  <tr>
    <td>open(screen, args = {})</td>
    <td>
      Pushes the screen onto the navigation stack or opens in a modal<br />
      Argument options:<br />
      <code>nav_bar: true|false</code><br />
      <code>hide_tab_bar: true|false</code><br />
      <code>modal: true|false</code><br />
      <code>close_all: true|false</code> (closes all open screens and opens as root...same as open_root_screen)<br />
      <code>animated: true:false</code> (currently only affects modals)<br />
      <code>in_tab: "Tab name"</code> (if you're in a tab bar)<br />
      Any accessors in <code>screen</code> can also be set in this hash.
    </td>
  </tr>
  <tr>
    <td>open_modal(screen, args = {})</td>
    <td>
      Same as <code>open HomeScreen, modal: true</code>
    </td>
  </tr>
  <tr>
    <td>open_split_screen(master, detail)</td>
    <td>
      *iPad apps only*
      Opens a UISplitScreenViewController with the specified screens as the root view controller of the current app<br />
    </td>
  </tr>
  <tr>
    <td>open_tab_bar(*screens)</td>
    <td>
      Opens a UITabBarController with the specified screens as the root view controller of the current app<br />
    </td>
  </tr>
  <tr>
    <td>open_tab(tab)</td>
    <td>
      Opens the tab where the "string" title matches the passed in tab<br />
    </td>
  </tr>
</table>

## TableScreen

*Has all the methods of Screen*

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>searchable(placeholder: "placeholder text")</td>
    <td>Class method to make the current table searchable.</td>
  </tr>
  <tr>
    <td><pre><code>refreshable(
  callback: :on_refresh,
  pull_message: "Pull to refresh",
  refreshing: "Refreshing data…",
  updated_format: "Last updated at %s",
  updated_time_format: "%l:%M %p"
)</code></pre></td>
    <td>Class method to make the current table refreshable.
      <p>All parameters are optional. If you do not specify a a callback, it will assume you've implemented an <code>on_refresh</code> method in your tableview.</p>
    <pre><code>def on_refresh
  # Code to start the refresh
end</code></pre>
    <p>And after you're done with your asyncronous process, call <code>end_refreshing</code> to collapse the refresh  view and update the last refreshed time and then <code>update_table_data</code>.</p></td>
    <img src="https://f.cloud.github.com/assets/139261/472574/af268e52-b735-11e2-8b9b-a9245b421715.gif" />
  </tr>
  <tr>
    <td colspan="2">
      <h3>table_data</h3>
      Method that is called to get the table's cell data and build the table.<br />
      Example format using nearly all available options.<br />
      <strong>Note...</strong> if you're getting crazy deep into styling your table cells,
      you really should be subclassing them and specifying that new class in <code>:cell_class</code>
      and then providing <code>:cell_class_attributes</code> to customize it.<br /><br />
      <strong>Performance note...</strong> It's best to build this array in a different method
      and store it in something like <code>@table_data</code>. Then your <code>table_data</code>
      method just returns that.

<pre><code>
def table_data
  [{
    title: "Table cell group 1",
    cells: [{
      title: "Simple cell",
      action: :this_cell_tapped,
      arguments: { id: 4 }
    }, {
      title: "Crazy Full Featured Cell",
      subtitle: "This is way too huge..see note",
      arguments: { data: [ "lots", "of", "data" ] },
      action: :tapped_cell_1,
      height: 50, # manually changes the cell's height
      cell_style: UITableViewCellStyleSubtitle,
      cell_identifier: "Cell",
      cell_class: PM::TableViewCell,
      masks_to_bounds: true,
      background_color: UIColor.whiteColor,
      selection_style: UITableViewCellSelectionStyleGray,
      cell_class_attributes: {
        # any Obj-C attributes to set on the cell
        backgroundColor: UIColor.whiteColor
      },
      accessory: :switch, # currently only :switch is supported
      accessory_view: @some_accessory_view,
      accessory_type: UITableViewCellAccessoryCheckmark,
      accessory_checked: true, # whether it's "checked" or not
      image: { image: UIImage.imageNamed("something"), radius: 15 },
      remote_image: {  # remote image, requires SDWebImage CocoaPod
        url: "http://placekitten.com/200/300", placeholder: "some-local-image",
        size: 50, radius: 15
      },
      subviews: [ @some_view, @some_other_view ] # arbitrary views added to the cell
    }]
  }, {
    title: "Table cell group 2",
    cells: [{
      title: "Log out",
      action: :log_out
    }]
  }]
end
</code></pre>
      <img src="http://clearsightstudio.github.com/ProMotion/img/ProMotion/full-featured-table-screen.png" />
    </td>
  </tr>
  <tr>
    <td>update_table_data</td>
    <td>
      Causes the table data to be refreshed, such as when a remote data source has
      been downloaded and processed.<br />
    </td>
  </tr>
</table>

## Logger

*Accessible from ProMotion.logger or PM.logger ... you can also set a new logger by setting `PM.logger = MyLogger.new`*

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>log(label, message_text, color)</td>
    <td>
      Output a colored console message.<br />
      Example: <code>PM.logger.log("TESTING", "This is red!", :red)</code>
    </td>
  </tr>
  <tr>
    <td>error(message)</td>
    <td>
      Output a red colored console error.<br />
      Example: <code>PM.logger.error("This is an error")</code>
    </td>
  </tr>
  <tr>
    <td>deprecated(message)</td>
    <td>
      Output a yellow colored console deprecated.<br />
      Example: <code>PM.logger.deprecated("This is a deprecation warning.")</code>
    </td>
  </tr>
  <tr>
    <td>warn(message)</td>
    <td>
      Output a yellow colored console warning.<br />
      Example: <code>PM.logger.warn("This is a warning")</code>
    </td>
  </tr>
  <tr>
    <td>debug(message)</td>
    <td>
      Output a purple colored console debug message.<br />
      Example: <code>PM.logger.debug(@some_var)</code>
    </td>
  </tr>
  <tr>
    <td>info(message)</td>
    <td>
      Output a green colored console info message.<br />
      Example: <code>PM.logger.info("This is an info message")</code>
    </td>
  </tr>
</table>

## Console [deprecated]

<table>
  <tr>
    <th>Method</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>log(log, with_color:color)<br />
        [DEPRECATED] -- use Logger
      </td>
    <td>
      Class method to output a colored console message.<br />
      Example: <code>PM::Console.log("This is red!", with_color: PM::Console::RED_COLOR)</code>
    </td>
  </tr>
</table>