# ProMotion [![Build Status](https://travis-ci.org/clearsightstudio/ProMotion.png)](https://travis-ci.org/clearsightstudio/ProMotion) [![Code Climate](https://codeclimate.com/github/clearsightstudio/ProMotion.png)](https://codeclimate.com/github/clearsightstudio/ProMotion)

## iPhone Apps, Ruby-style

ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.
It introduces a clean, Ruby-style syntax for building screens that is easy to learn and remember and
abstracts a ton of boilerplate UIViewController, UINavigationController, and other iOS code into a
simple, Ruby-like DSL.

Watch the [September Motion Meetup](http://www.youtube.com/watch?v=rf7h-3AiMRQ) where Gant Laborde
interviews Jamon Holmgren about ProMotion!

```ruby
# app/app_delegate.rb
class AppDelegate < PM::Delegate
  def on_load(app, options)
    open RootScreen.new(nav_bar: true)
  end
end

# app/screens/root_screen.rb
class RootScreen < PM::Screen
  title "Root Screen"

  def on_load
    set_nav_bar_button :right, title: "Help", action: :help
  end

  def help
    open HelpScreen
  end
end

# app/screens/help_screen.rb
class HelpScreen < PM::TableScreen
  title "Table Screen"

  def table_data
    [{
      title: "Help",
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
|![ProMotion TableScreen](https://f.cloud.github.com/assets/1479215/1534137/ed71e864-4c90-11e3-98aa-ed96049f5407.png)|![Grouped Table Screen](https://f.cloud.github.com/assets/1479215/1589973/61a48610-5281-11e3-85ac-abee99bf73ad.png)|![Searchable](https://f.cloud.github.com/assets/1479215/1534299/20cc05c6-4c93-11e3-92ca-9ee39c044457.png)|![Refreshable](https://f.cloud.github.com/assets/1479215/1534317/5a14ef28-4c93-11e3-8e9e-f8c08d8464f8.png)|


|iPad SplitScreens|Map Screens|Web Screens|
|---|---|---|
|![ProMotion SplitScreens](https://f.cloud.github.com/assets/1479215/1534507/0edb8dd4-4c96-11e3-9896-d4583d0ed161.png)|![MapScreen](https://f.cloud.github.com/assets/1479215/1534628/f7dbf7e8-4c97-11e3-8817-4c2a58824771.png)|![ProMotion WebScreen](https://f.cloud.github.com/assets/1479215/1534631/ffe1b36a-4c97-11e3-8c8f-c7b14e26182d.png)|

#### ...and much more.

# Getting Started

1. Check out the [Getting Started Guide](https://github.com/clearsightstudio/ProMotion/wiki/Guide:-Getting-Started) in the wiki
2. Follow a tutorial: [Building an ESPN app using RubyMotion, ProMotion, and TDD](http://jamonholmgren.com/building-an-espn-app-using-rubymotion-promotion-and-tdd)

# What's New?

## Version 1.1.x

* Added a [ProMotion executable](https://github.com/clearsightstudio/ProMotion/wiki/Command-Line-Tool) called `promotion`. You can type `promotion new <myapp>` and it will create a ProMotion-specific app. We will be adding more functionality in the future.
* Can now pass a symbol to `add`, `add_to`, and `set_attributes` to call a method with that name to get styles.
* Added `button_title:` to `open_split_screen` to [customize the auto-generated button title](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::SplitScreen#open_split_screenmaster-detail-args--)
* Updates to [set_tab_bar_button](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::Tabs#set_tab_bar_itemargs)
* Added to PM::Delegate [`on_open_url(args = {})`](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::Delegate#on_open_urlargs--) where `args` contains `:url`, `:source_app`, and `:annotation`
* Added to PM::Delegate [`tint_color`](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::Delegate#tint_color) to customize the application-wide tint color
* Added to [PM::MapScreen annotations](https://github.com/clearsightstudio/ProMotion/wiki/API-Reference:-ProMotion::MapScreen) the ability to set an image
* Removed legacy `navigation_controller` references which were causing confusion.
* Allowed setting a `custom_view` for `bar_button_item`s.
* Added `will_begin_search` and `will_end_search` callbacks to PM::TableScreen.
* Added `title_view` and `title_view_height` to sections in PM::TableScreen.
* Updated screenshots for iOS 7
* Refactored code and lots of new passing tests

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

If you need help, feel free to tweet [@jamonholmgren](http://twitter.com/jamonholmgren)
or open an issue on GitHub. Opening an issue is usually the best and we respond to those pretty quickly.
If we don't respond within a day, tweet Jamon or Mark a link to the issue.

# Contributing

See [CONTRIBUTING.md](https://github.com/clearsightstudio/ProMotion/edit/master/CONTRIBUTING.md).

## Primary Contributors

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* Matt Brewer: [@macfanatic](https://twitter.com/macfanatic)
* Mark Rickert: [@markrickert](https://twitter.com/markrickert)
* [Many others](https://github.com/clearsightstudio/ProMotion/graphs/contributors)
* Run `git shortlog -s -n -e` to see everyone who has contributed.

