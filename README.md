# ProMotion [![Gem Version](https://badge.fury.io/rb/ProMotion.png)](http://badge.fury.io/rb/ProMotion) [![Build Status](https://travis-ci.org/clearsightstudio/ProMotion.png)](https://travis-ci.org/clearsightstudio/ProMotion) [![Code Climate](https://codeclimate.com/github/clearsightstudio/ProMotion.png)](https://codeclimate.com/github/clearsightstudio/ProMotion) [![Dependency Status](https://gemnasium.com/clearsightstudio/ProMotion.png)](https://gemnasium.com/clearsightstudio/ProMotion)

## iPhone Apps, Ruby-style

ProMotion is a RubyMotion gem that makes iOS development more like Ruby and less like Objective-C.
It introduces a clean, Ruby-style syntax for building screens that is easy to learn and remember and
abstracts a ton of boilerplate UIViewController, UINavigationController, and other iOS code into a
simple, Ruby-like DSL.

* Watch Jamon Holmgren give a talk about ProMotion at [RubyMotion #inspect2014](#) (coming soon)
* Watch the [September 2013 Motion Meetup](http://www.youtube.com/watch?v=rf7h-3AiMRQ) where Gant Laborde
interviews Jamon Holmgren about ProMotion!

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
2. Watch the excellent [MotionInMotion screencast about ProMotion](https://motioninmotion.tv/screencasts/8) (very reasonably priced subscription required)
3. Follow a tutorial: [Building an ESPN app using RubyMotion, ProMotion, and TDD](http://jamonholmgren.com/building-an-espn-app-using-rubymotion-promotion-and-tdd)

# What's New?

## Version 2.0.0

1. Now uses [motion-require](https://github.com/clayallsopp/motion-require) for better compatibility with other libraries [6046dd7f4](https://github.com/clearsightstudio/ProMotion/commit/6046dd7f49ba174f309baaa428eaac80ce0290b6)
2. SplitScreen: New option `swipe:` allows you to specify if a splitscreen master screen can be opened with a swipe. [ffbb76caf](https://github.com/clearsightstudio/ProMotion/commit/ffbb76caf3071297347d4cf43784069999a746b3)
3. FormotionScreen: Removed `PM::FormotionScreen` and the Formotion testing dependency. Use [ProMotion-formotion](https://github.com/rheoli/ProMotion-formotion) instead.
4. Styling: Added a `content_width` helper to PM::Styling (similar to `content_height`) [08a984815](https://github.com/clearsightstudio/ProMotion/commit/08a984815a7c96b9465c31b2e2664ac0086d2e1c)
5. TableScreen: Removed SDWebImage in favor of similar but more reliable JDImageCache [59ed747e9](https://github.com/clearsightstudio/ProMotion/commit/59ed747e93567e32bdb5099fed12297161cea05a)
6. Screen: Allow custom views (including images) for `title` setting [#415](https://github.com/clearsightstudio/ProMotion/pull/415)

# API Reference

We've created a comprehensive and always updated wiki with code examples, usage examples, and API reference.

### [ProMotion API Reference](https://github.com/clearsightstudio/ProMotion/wiki)

# Help

ProMotion is not only an easy DSL to get started. The community is very helpful and
welcoming to new RubyMotion developers. We don't mind newbie questions.

If you need help, feel free to tweet [@jamonholmgren](http://twitter.com/jamonholmgren)
or open an issue on GitHub. Opening an issue is usually the best and we respond to those
pretty quickly. If we don't respond within a day, tweet Jamon or Mark a link to the issue.

# Contributing

See [CONTRIBUTING.md](https://github.com/clearsightstudio/ProMotion/blob/master/CONTRIBUTING.md).

## Primary Contributors

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* Matt Brewer: [@macfanatic](https://twitter.com/macfanatic)
* Mark Rickert: [@markrickert](https://twitter.com/markrickert)
* [Many others](https://github.com/clearsightstudio/ProMotion/graphs/contributors)
