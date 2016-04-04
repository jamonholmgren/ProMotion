### Contents

* [Usage](#usage)
* [Methods](#methods)
* [Class Methods](#class-methods)
* [Accessors](#accessors)

---

### Usage

*Has all the methods of PM::Screen*

Easily create a web-based view from an external URL, internal HTML file, or HTML string.

```ruby
open MyWebScreen.new(nav_bar: true, external_links: false)
```

```ruby
class MyWebScreen < PM::WebScreen

  title "Title of Screen"

  def content
  	# You can return:
  	#  1. A reference to a file placed in your resources directory
  	#  2. An instance of NSURL
        #  3. An arbitrary HTML string
    "AboutView.html"
  end

  def load_started
    # Optional
    # Called when the request starts to load
  end

  def load_finished
    # Optional
    # Called when the request is finished
  end

  def load_failed(error)
    # Optional
    # "error" is an instance of NSError
  end

end
```

#### Initialization Options

```ruby
external_links: false
```

**Default:** false
**Behavior:** true causes all links clicked in the `WebScreen` to open in Safari (or Chrome).

```ruby
detector_types: [:none, :phone, :link, :address, :event, :all]
```

**Default:** :none  
**Behavior:** An array of any of the above values to specify what sort of detectors you'd like the webview to auto-link for you. [You can read more about `UIDataDetector`s here](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIKitDataTypesReference/Reference/reference.html).

### Opening External Links in Chrome

If you want your users to have links open in the Google Chrome iOS app, simply add this to your `Rakefile`:

```ruby
app.pods do
  pod 'OpenInChrome'
end
```

This will change the default behavior of your app to check and see if Chrome is installed and if so, open the link in Chrome. Otherwise, the links will open in Safari.

### Methods

#### set_content(content)

Causes the `WebScreen` to load new content (where `content` is a string reference to a local file in the `resources` directory or an `NSURL` or an arbitrary bit of HTML).

#### html

Returns the current HTML contained in the `WebScreen` as a string.

#### can_go_back

Returns a `boolean` if the user can navigate backwards (e.g., if there's anything in the history).

#### can_go_forward

Returns a `boolean` if the user can navigate forwards.

#### back

Navigates back one page.

#### forward

Navigates forward one page.

#### refresh

Refreshes the current URL. Alias: `reload`

#### stop

Cancels the current URL request and stops loading the page.

---

### Class Methods

None.

---

### Accessors

#### webview

Reference to the UIWebView that is automatically created.

#### external_links

TODO

#### detector_types

TODO
