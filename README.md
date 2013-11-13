# ProMotion [![Build Status](https://travis-ci.org/clearsightstudio/ProMotion.png)](https://travis-ci.org/clearsightstudio/ProMotion) [![Code Climate](https://codeclimate.com/github/clearsightstudio/ProMotion.png)](https://codeclimate.com/github/clearsightstudio/ProMotion)

## iPhone Apps, Ruby-style

ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.
It introduces a clean, Ruby-style syntax for building screens that is easy to learn and remember and
abstracts a ton of boilerplate UIViewController, UINavigationController, and other iOS code into a
simple, Ruby-like DSL.

Watch the [September Motion Meetup](http://www.youtube.com/watch?v=rf7h-3AiMRQ) where Gant Laborde
interviews Jamon Holmgren about ProMotion!

```ruby
class AppDelegate < PM::Delegate
  def on_load(app, options)
    open RootScreen.new(nav_bar: true)
  end
end

class RootScreen < PM::Screen
  title "Root Screen"

  def push_new_screen
    open NewScreen
  end
end

class NewScreen < PM::TableScreen
  title "Table Screen"

  def table_data
    [{
      cells: [
        { title: "About this app", action: :tapped_about },
        { title: "Log out", action: :log_out }
      ]
    }]
  end
end
```

# Features

|Screens|Navigation Bars|Tab Bars|
|---|---|---|
|![ProMotion Screen](https://f.cloud.github.com/assets/1479215/1534021/060aaaac-4c8f-11e3-903c-743e54252222.png)|![ProMotion Nav Bar](https://f.cloud.github.com/assets/1479215/1534077/db39aab6-4c8f-11e3-83f7-e03d52ac615d.png)|![ProMotion Tabs](https://f.cloud.github.com/assets/1479215/1534115/9f4c4cd8-4c90-11e3-9285-96ac253facda.png)|

|Table Screens|Grouped Tables|Searchable|Refreshable|
|---|---|---|---|
|![ProMotion TableScreen](https://f.cloud.github.com/assets/1479215/1534137/ed71e864-4c90-11e3-98aa-ed96049f5407.png)|*Screenshot coming soon!*|![Searchable](https://f.cloud.github.com/assets/1479215/1534299/20cc05c6-4c93-11e3-92ca-9ee39c044457.png)|![Refreshable](https://f.cloud.github.com/assets/1479215/1534317/5a14ef28-4c93-11e3-8e9e-f8c08d8464f8.png)|


|iPad SplitScreens|Map Screens|Web Screens|
|---|---|---|
|![ProMotion SplitScreens](https://f.cloud.github.com/assets/1479215/1534507/0edb8dd4-4c96-11e3-9896-d4583d0ed161.png)|![MapScreen](https://f.cloud.github.com/assets/1479215/1534628/f7dbf7e8-4c97-11e3-8817-4c2a58824771.png)|![ProMotion WebScreen](https://f.cloud.github.com/assets/1479215/1534631/ffe1b36a-4c97-11e3-8c8f-c7b14e26182d.png)|

#### ...and much more.

# Getting Started

Check out our new [Getting Started Guide](https://github.com/clearsightstudio/ProMotion/wiki/Guide:-Getting-Started) in the wiki!

# What's New?

## Version 1.0

* **New Screen** [`PM::MapScreen`](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::MapScreen)
* **New Screen** [`PM::WebScreen`](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::WebScreen)
* Added [`indexable`](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::TableScreen#indexable) as a `PM::TableScreen` feature
* Added `PM::SplitViewController` and the ability to open a screen `in_detail:` or `in_master:`. [More info here.](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::Screen#openscreen-args--)
* Added `PM::TabBarController` and `PM::Tabs` and refactored the `open_tab_bar` code
* **IMPORTANT:** Changed `on_load` to fire more consistently. You are now encouraged to put your view setup code in here rather than `will_appear`.
* Many methods that used to require long UIKit constants now take short :symbols. Check documentation.
* Simpler `PM::Delegate` code, added `will_load(app, options)` and others. [See the documentation.](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::Delegate)
* [Added a few keys and improvements](https://github.com/clearsightstudio/ProMotion/wiki/Reference%3A-All-available-table_data-options) to table_data
* Removed `PM::SectionedTableScreen` (`PM::TableScreen` is already a sectioned table)
* Removed any last UIKit monkeypatching. Everything is a subclass now. ProMotion is probably the least invasive RubyMotion gem in common use.
* Push Notification updates
* Renamed `PM::ViewHelper` to `PM::Styling` and [added some common helpers](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::Screen#hex_colorstr)
* Added `will_present`, `on_present`, `will_dismiss`, `on_dismiss` to screens
* Major internal refactors everywhere
* Lots of new unit & functional tests
* Removed deprecations, cleaned up a lot of code
* Huge improvements to the [wiki](https://github.com/clearsightstudio/ProMotion/wiki)

# Tutorials

Shows how to make a basic app in ProMotion. Updated in May.

[http://www.clearsightstudio.com/insights/ruby-motion-promotion-tutorial](http://www.clearsightstudio.com/insights/ruby-motion-promotion-tutorial)

## Screencasts

Shows how to create a Youtube app that shows Portland Trailblazer highlights.

[http://www.clearsightstudio.com/insights/tutorial-make-youtube-video-app-rubymotion-promotion/](http://www.clearsightstudio.com/insights/tutorial-make-youtube-video-app-rubymotion-promotion/)

## Sample Apps

Here's a demo app that is used to test new functionality. You might have to change the Gemfile
source to pull from Github.

[https://github.com/jamonholmgren/promotion-demo](https://github.com/jamonholmgren/promotion-demo)

Here's a demo app showing some styling options.

[https://github.com/jamonholmgren/promotion-styling](https://github.com/jamonholmgren/promotion-styling)

# API Reference

We've created a comprehensive and always updated wiki with code examples, usage examples, and API reference.

### [ProMotion API Reference](https://github.com/clearsightstudio/ProMotion/wiki)

# Help

If you need help, feel free to ping me on twitter [@jamonholmgren](http://twitter.com/jamonholmgren)
or open an issue on GitHub. Opening an issue is usually the best and we respond to those pretty quickly.

# Contributing

I'm very open to ideas. Tweet me with your ideas or open a ticket (I don't mind!)
and let's discuss. **It's a good idea to run your idea by the committers before creating
a pull request.** We'll always consider your ideas carefully but not all ideas will be
incorporated.

## Working on New Features

1. Clone the repos into `Your-Project/Vendor/ProMotion`
2. Update your `Gemfile`to reference the project as `gem 'ProMotion', :path => "vendor/ProMotion/"`
3. Run `bundle`
4. Run `rake clean` and then `rake`
5. Contribute!

## Submitting a Pull Request

1. Fork the project
2. Create a feature branch
3. Code
4. Update or create new specs ** NOTE: your PR is far more likely to be merged if you include comprehensive tests! **
5. Make sure tests are passing by running `rake spec` *(you can run functional and unit specs separately with `rake spec:functional` and `rake spec:unit`)*
6. Submit pull request to `edge` (for new features) or `master` (for bugfixes)
7. Make a million little nitpicky changes that @jamonholmgren wants
8. Merged, then fame, adoration, kudos everywhere

## Primary Contributors

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* Matt Brewer: [@macfanatic](https://twitter.com/macfanatic)
* Mark Rickert: [@markrickert](https://twitter.com/markrickert)
* [Many others](https://github.com/clearsightstudio/ProMotion/graphs/contributors)
* Run `git shortlog -s -n -e` to see everyone who has contributed.

