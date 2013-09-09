# ProMotion [![Build Status](https://travis-ci.org/clearsightstudio/ProMotion.png)](https://travis-ci.org/clearsightstudio/ProMotion) [![Code Climate](https://codeclimate.com/github/clearsightstudio/ProMotion.png)](https://codeclimate.com/github/clearsightstudio/ProMotion)

## A new way to easily build RubyMotion apps.

ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.
It introduces a clean, Ruby-style syntax for building screens that is easy to learn and remember and
abstracts a ton of boilerplate UIViewController, UINavigationController, and other iOS code into a
simple, Ruby-like DSL.

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
|![ProMotion Screen](https://f.cloud.github.com/assets/1479215/751058/486b6e1e-e4e7-11e2-9d1f-d9380a58f643.png)|![ProMotion Nav Bar](https://f.cloud.github.com/assets/1479215/751076/e4762858-e4e7-11e2-8442-ac7c9ad142e6.png)|![ProMotion Tabs](https://f.cloud.github.com/assets/1479215/751128/76ebe320-e4e9-11e2-86ee-d81c4c1e92f2.png)|

|Table Screens|Grouped Tables|Searchable|Refreshable|
|---|---|---|---|
|![ProMotion TableScreen](https://f.cloud.github.com/assets/1479215/751067/8fe7631a-e4e7-11e2-84f1-6ae50ac4f8e8.png)|![ProMotion Grouped Table Screens](https://f.cloud.github.com/assets/1479215/751162/a805b9da-e4ea-11e2-9c39-0c65f8a8de77.png)|![Searchable](https://f.cloud.github.com/assets/1479215/707490/ba750216-de1d-11e2-9594-0880b12f8ffe.png)|![Refreshable](https://f.cloud.github.com/assets/139261/472574/af268e52-b735-11e2-8b9b-a9245b421715.gif)|


|iPad SplitScreens|Map Screens|Web Screens|
|---|---|---|
|![ProMotion SplitScreens](https://f.cloud.github.com/assets/1479215/751188/13c3a7c6-e4ec-11e2-8c87-a94e0c07702b.png)|![MapScreen](https://f.cloud.github.com/assets/1479215/751217/dab20958-e4ed-11e2-9b3e-b42c0199d9e7.png)|![ProMotion WebScreen](https://f.cloud.github.com/assets/1479215/751235/b6fe91ba-e4ee-11e2-8707-c74c7f833de3.png)|

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
6. Submit pull request
7. Make a million little nitpicky changes that @jamonholmgren wants
8. Merged, then fame, adoration, kudos everywhere

## Primary Contributors

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* Matt Brewer: [@macfanatic](https://twitter.com/macfanatic)
* Mark Rickert: [@markrickert](https://twitter.com/markrickert)
* [Many others](https://github.com/clearsightstudio/ProMotion/graphs/contributors)
* Run `git shortlog -s -n -e` to see everyone who has contributed.

