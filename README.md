# ProMotion

[![Gem Version](https://img.shields.io/gem/v/ProMotion.svg?style=flat)](https://rubygems.org/gems/ProMotion)

ProMotion was created by me, Jamon Holmgren. While you're welcome to use ProMotion, please note that it's no longer maintained!

(And yes -- I created it long before [Apple launched their own ProMotion](https://www.apple.com/newsroom/2017/06/ipad-pro-10-5-and-12-9-inch-models-introduces-worlds-most-advanced-display-breakthrough-performance/).)

## iPhone Apps, Ruby-style

ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.
It introduces a clean, Ruby-style syntax for building screens that is easy to learn and remember and
abstracts a ton of boilerplate UIViewController, UINavigationController, and other iOS code into a
simple, Ruby-like DSL.

```ruby
# app/app_delegate.rb
class AppDelegate < PM::Delegate
  status_bar true, animation: :fade

  def on_load(app, options)
    open RootScreen
  end
end

# app/screens/root_screen.rb
class RootScreen < PM::Screen
  title "Root Screen"
  nav_bar true

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

## Features

|Screens|Navigation Bars|Tab Bars|
|---|---|---|
|[![ProMotion Screen](https://f.cloud.github.com/assets/1479215/1534021/060aaaac-4c8f-11e3-903c-743e54252222.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20Screen/)|[![ProMotion Nav Bar](https://f.cloud.github.com/assets/1479215/1534077/db39aab6-4c8f-11e3-83f7-e03d52ac615d.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20Screen/#set_nav_bar_buttonside-args)|[![ProMotion Tabs](https://f.cloud.github.com/assets/1479215/1534115/9f4c4cd8-4c90-11e3-9285-96ac253facda.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20Tabs/)|

|Table Screens|Grouped Tables|Searchable|Refreshable|
|---|---|---|---|
|[![ProMotion TableScreen](https://f.cloud.github.com/assets/1479215/1534137/ed71e864-4c90-11e3-98aa-ed96049f5407.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20TableScreen/)|[![Grouped Table Screen](https://f.cloud.github.com/assets/1479215/1589973/61a48610-5281-11e3-85ac-abee99bf73ad.png)](https://gist.github.com/jamonholmgren/382a6cf9963c5f0b2248)|[![Searchable](https://f.cloud.github.com/assets/1479215/1534299/20cc05c6-4c93-11e3-92ca-9ee39c044457.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20TableScreen/#searchableplaceholder-placeholder-text)|[![Refreshable](https://f.cloud.github.com/assets/1479215/1534317/5a14ef28-4c93-11e3-8e9e-f8c08d8464f8.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20TableScreen/#refreshableoptions)|


|SplitScreens|Map Screens|Web Screens|
|---|---|---|
|[![ProMotion SplitScreens](https://f.cloud.github.com/assets/1479215/1534507/0edb8dd4-4c96-11e3-9896-d4583d0ed161.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20SplitScreen/)|[![MapScreen](https://f.cloud.github.com/assets/1479215/1534628/f7dbf7e8-4c97-11e3-8817-4c2a58824771.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20MapScreen/)|[![ProMotion WebScreen](https://f.cloud.github.com/assets/1479215/1534631/ffe1b36a-4c97-11e3-8c8f-c7b14e26182d.png)](http://promotion.readthedocs.org/en/master/Reference/ProMotion%20WebScreen/)|

#### ...and much more.

## Getting Started

1. Check out the [Getting Started Guide](https://github.com/infinitered/ProMotion/blob/master/docs/Guides/Getting%20Started.md)
2. Watch the excellent [MotionInMotion screencast about ProMotion](https://motioninmotion.tv/screencasts/8) (very reasonably priced subscription required)
3. Follow a tutorial: [Building an ESPN app using RubyMotion, ProMotion, and TDD](http://jamonholmgren.com/building-an-espn-app-using-rubymotion-promotion-and-tdd)
4. Read the [Documentation](https://github.com/infinitered/ProMotion/blob/master/docs)

## Changelog

[See Releases page](https://github.com/infinitered/ProMotion/releases)

## Apps built on ProMotion

[Apps built on ProMotion](http://promotion.readthedocs.org/en/master/ProMotion%20Apps/)

## Your app

Open a pull request! We love adding new ProMotion-built apps.

## API Reference

We have comprehensive documentation with code examples, usage examples, and API reference.

### [ProMotion Documentation](https://github.com/infinitered/ProMotion/blob/master/docs)

## Screencasts

* Watch Jamon Holmgren give a talk about ProMotion at [RubyMotion #inspect2014](http://confreaks.com/videos/3813-inspect-going-pro-with-promotion-from-prototype-to-production) (video)
* Watch the [September 2013 Motion Meetup](http://www.youtube.com/watch?v=rf7h-3AiMRQ) where Gant Laborde
interviews Jamon Holmgren about ProMotion

## Help

We're no longer supporting ProMotion and it's mostly retired. If you need help, feel free to file an issue, but I may not see it.

## Contributing

See [CONTRIBUTING.md](https://github.com/infinitered/ProMotion/blob/master/CONTRIBUTING.md).

## Core Team (inactive)

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Andrew Havens: [@misbehavens](https://twitter.com/misbehavens)
* Mark Rickert: [@markrickert](https://twitter.com/markrickert)
* Ryan Linton: [@ryanlntn](https://twitter.com/ryanlntn)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* David Larrabee: [@squidpunch](https://twitter.com/squidpunch)

## Other Contributors

* [Many others](https://github.com/infinitered/ProMotion/graphs/contributors)
