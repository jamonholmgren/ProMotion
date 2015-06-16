# ProMotion

[![Gem Version](https://img.shields.io/gem/v/ProMotion.svg?style=flat)](https://rubygems.org/gems/ProMotion)
[![Build Status](https://img.shields.io/travis/clearsightstudio/ProMotion.svg?style=flat)](https://travis-ci.org/clearsightstudio/ProMotion)
[![Code Climate](https://img.shields.io/codeclimate/github/clearsightstudio/ProMotion.svg?style=flat)](https://codeclimate.com/github/clearsightstudio/ProMotion)
[![Dependency Status](https://img.shields.io/gemnasium/clearsightstudio/ProMotion.svg?style=flat)](https://gemnasium.com/clearsightstudio/ProMotion)
[![omniref](https://img.shields.io/badge/omniref-docs-blue.svg?style=flat)](https://www.omniref.com/ruby/gems/ProMotion)
[![Stories in Ready](https://badge.waffle.io/clearsightstudio/ProMotion.png?label=ready&title=Ready)](https://waffle.io/clearsightstudio/ProMotion)

## iPhone Apps, Ruby-style

ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.
It introduces a clean, Ruby-style syntax for building screens that is easy to learn and remember and
abstracts a ton of boilerplate UIViewController, UINavigationController, and other iOS code into a
simple, Ruby-like DSL.

* Watch Jamon Holmgren give a talk about ProMotion at [RubyMotion #inspect2014](http://confreaks.com/videos/3813-inspect-going-pro-with-promotion-from-prototype-to-production) (video)
* Watch the [September 2013 Motion Meetup](http://www.youtube.com/watch?v=rf7h-3AiMRQ) where Gant Laborde
interviews Jamon Holmgren about ProMotion

```ruby
# app/app_delegate.rb
class AppDelegate < PM::Delegate
  status_bar true, animation: :fade

  def on_load(app, options)
    open RootScreen.new(nav_bar: true)
  end
end

# app/screens/root_screen.rb
class RootScreen < PM::Screen
  title "Root Screen"

  def on_load
    set_nav_bar_button :right, title: "Help", action: :open_help_screen
  end

  def open_help_screen
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

  def tapped_about(args={})
    open AboutScreen
  end

  def log_out
    # Log out!
  end
end
```

# Features

|Screens|Navigation Bars|Tab Bars|
|---|---|---|
|[![ProMotion Screen](https://f.cloud.github.com/assets/1479215/1534021/060aaaac-4c8f-11e3-903c-743e54252222.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20Screen/)|[![ProMotion Nav Bar](https://f.cloud.github.com/assets/1479215/1534077/db39aab6-4c8f-11e3-83f7-e03d52ac615d.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20Screen/#set_nav_bar_buttonside-args)|[![ProMotion Tabs](https://f.cloud.github.com/assets/1479215/1534115/9f4c4cd8-4c90-11e3-9285-96ac253facda.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20Tabs/)|

|Table Screens|Grouped Tables|Searchable|Refreshable|
|---|---|---|---|
|[![ProMotion TableScreen](https://f.cloud.github.com/assets/1479215/1534137/ed71e864-4c90-11e3-98aa-ed96049f5407.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20TableScreen/)|[![Grouped Table Screen](https://f.cloud.github.com/assets/1479215/1589973/61a48610-5281-11e3-85ac-abee99bf73ad.png)](https://gist.github.com/jamonholmgren/382a6cf9963c5f0b2248)|[![Searchable](https://f.cloud.github.com/assets/1479215/1534299/20cc05c6-4c93-11e3-92ca-9ee39c044457.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20TableScreen/#searchableplaceholder-placeholder-text)|[![Refreshable](https://f.cloud.github.com/assets/1479215/1534317/5a14ef28-4c93-11e3-8e9e-f8c08d8464f8.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20TableScreen/#refreshableoptions)|


|SplitScreens|Map Screens|Web Screens|
|---|---|---|
|[![ProMotion SplitScreens](https://f.cloud.github.com/assets/1479215/1534507/0edb8dd4-4c96-11e3-9896-d4583d0ed161.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20SplitScreen/)|[![MapScreen](https://f.cloud.github.com/assets/1479215/1534628/f7dbf7e8-4c97-11e3-8817-4c2a58824771.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20MapScreen/)|[![ProMotion WebScreen](https://f.cloud.github.com/assets/1479215/1534631/ffe1b36a-4c97-11e3-8c8f-c7b14e26182d.png)](http://promotion.readthedocs.org/en/master/Reference/API%20Reference%20-%20ProMotion%20WebScreen/)|

#### ...and much more.

# Getting Started

1. Check out the [Getting Started Guide](https://github.com/clearsightstudio/ProMotion/blob/master/docs/Guides/Guide%20-%20Getting%20Started.md)
2. Watch the excellent [MotionInMotion screencast about ProMotion](https://motioninmotion.tv/screencasts/8) (very reasonably priced subscription required)
3. Follow a tutorial: [Building an ESPN app using RubyMotion, ProMotion, and TDD](http://jamonholmgren.com/building-an-espn-app-using-rubymotion-promotion-and-tdd)
4. Read the [Documentation](https://github.com/clearsightstudio/ProMotion/blob/master/docs)

# Changelog

## Version 2.4.0

This release includes several new features and is backwards compatible with all 2.x releases.

* PR #686 Adds :searchable to the whitelisted properties a cell can have so that a warning is not generated.
* PR #688 Adds support for SDWebImage and takes preference over JMImageCache. _JMImageCache will still be supported till ProMotion 3.0 but we highly recommend you switch to SDWebImage._
* PR #679 Extract methods from tablescreen for reuse in modules for [redpotion](https://github.com/infinitered/redpotion).
* PR #677 Added `add_child_screen` and `remove_child_screen` methods to `PM::Screen`.
* PR #687 Adds persisting tab order when changed by the user for tab bars over 5 screens.

## Version 2.3.0

This release includes several new features and is backwards compatible with all 2.x releases.

* PR #618 Allow search bar to be hidden initially
* PR #606 Adds capability for table_footer_view
* PR #602 Add image inset support for tab bar item
* PR #595 Feature/support module
* PR #582 Allow setting of multiple nav bar buttons instead of just one left an one right
* PR #581 Adds on_tab_selected
* PR #579 implemented nav_bar_button class method RE #272
* PR #565 Adds header_will_display method to PM::TableScreen
* PR #663 Adds `on_load` back to cell dequeue code
* PR #641 Custom search for PM::TableScreen
* PR #658 Fix cell height issue

# Apps built on ProMotion

[Apps built on ProMotion](http://promotion.readthedocs.org/en/master/ProMotion%20Apps/)

## Your app

Open a pull request!

# API Reference

We've created a comprehensive and always updated wiki with code examples, usage examples, and API reference.

### [ProMotion Documentation](https://github.com/clearsightstudio/ProMotion/blob/master/docs)

# Help

ProMotion is not only an easy DSL to get started. The community is very helpful and
welcoming to new RubyMotion developers. We don't mind newbie questions.

If you need help, feel free to open an issue on GitHub. If we don't respond within a day, tweet us a link to the issue -- sometimes we get busy.

# Contributing

See [CONTRIBUTING.md](https://github.com/clearsightstudio/ProMotion/blob/master/CONTRIBUTING.md).

## Core Team

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* Mark Rickert: [@markrickert](https://twitter.com/markrickert)
* Ryan Linton: [@ryanlntn](https://twitter.com/ryanlntn)
* David Larrabee: [@squidpunch](https://twitter.com/squidpunch)

## Other Contributors

* [Many others](https://github.com/clearsightstudio/ProMotion/graphs/contributors)
