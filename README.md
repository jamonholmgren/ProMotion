# ProMotion [![Gem Version](https://badge.fury.io/rb/ProMotion.png)](http://badge.fury.io/rb/ProMotion) [![Build Status](https://travis-ci.org/clearsightstudio/ProMotion.png)](https://travis-ci.org/clearsightstudio/ProMotion) [![Code Climate](https://codeclimate.com/github/clearsightstudio/ProMotion.png)](https://codeclimate.com/github/clearsightstudio/ProMotion) [![Dependency Status](https://gemnasium.com/clearsightstudio/ProMotion.png)](https://gemnasium.com/clearsightstudio/ProMotion) [![ProMotion OmniRef Documentation](https://www.omniref.com/ruby/gems/ProMotion.png)](https://www.omniref.com/ruby/gems/ProMotion)

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
4. Read the updated and exhaustive [Wiki](https://github.com/clearsightstudio/ProMotion/wiki)

# Changelog

## Version 2.0.0

Overview: In ProMotion 2.0, we removed deprecated APIs, refactored and cleaned up a ton of code, pulled `PushNotification` and `MapScreen` into their own gems, and simplified the API. It now builds 55% faster and is 20%+ lighter.

Follow our [Migration Guide](https://github.com/clearsightstudio/ProMotion/wiki/Migration-Guide:-ProMotion-1.2-to-2.0) for a painless upgrade.

**API changes**

1. Extracted `PM::MapScreen` into [ProMotion-map](https://github.com/clearsightstudio/ProMotion-map)
2. Extracted `PM::PushNotification` into [ProMotion-push](https://github.com/clearsightstudio/ProMotion-push)
3. You can't pass a UIImage or UIView into a `title` anymore. Instead, pass a string into `title_image` (it'll fetch the image for you and create a UIImageView) or pass any arbitrary view into `title_view`. Now, `title` only takes a string title.
4. `on_create` has been renamed `screen_init` to avoid confusion with Android's `onCreate` method. It may be reintroduced in a future version of ProMotion as an alias of `onCreate`. We recommend using `on_init` instead.
5. `set_nav_bar_right_button` and `set_nav_bar_left_button` have been removed. Use `set_nav_bar_button :right` and `:left` instead.
6. Added `NSString#to_url` and `NSURL#to_url` helper methods to help clean up a lot of code.
7. `present_modal_view_controller` now takes two arguments: the ViewController and an argument hash. You shouldn't have been using it in the first place.
8. `open_in_tab` now properly opens screens in tabs that didn't have a nav_bar. This is probably the closest thing to a new feature in PM 2.0 that we have, even though it should have worked before.
9. Cell hash arbitrary values are no longer applied directly to the cell. Instead, use the style: hash to apply arbitrary attributes. [Example here](https://github.com/clearsightstudio/ProMotion/pull/457/files#discussion_r13211807).
10. Removed cell hash `:subviews` attribute. Instead, subclass `PM::TableViewCell` and add your own subviews there.
11. Actually, there is one new feature. It's called `longpressable`. By adding `longpressable` at the top of your `PM::TableScreen` and then supplying a `long_press_action:` in your cell hash, you can implement a different action for long presses on table cells.
12. We no longer insert the cell hash into the arguments hash passed into your cell tap action. If you need that data, pass it in manually.
13. Removed `add_element`, `add_view`, `remove_element`, `remove_view` aliases for `add` and `remove`.
14. `on_load` now fires on `viewDidLoad` instead of `loadView`. Added a new `load_view` hook for that method & you can set your own view in there. If you don't implement `load_view`, one will be created for you (per Apple's recommendations). This change shouldn't change much in your app except that if you're setting `self.view = something`, you should do it in `load_view`.

**Internal changes:**

1. Removed `motion-require`. ProMotion now relies entirely on RubyMotion's built-in dependency detector.
2. Removed `rake spec:unit`, `rake spec:func`, `rake spec:single filename`. We don't really use these for development anymore.
3. Moved many files around into a more logical, simpler structure.
4. Removed `PM::Conversions`. The only helper we were using was the `objective_c_method_name` method, and that was only used in `PM::Styling`. So we moved it there.
5. New module, `PM::NavBarModule`. Moved any navigation controller methods into this module, cleaning up the `PM::ScreenModule` quite a bit.
6. Lots of code refactoring -- CodeClimate went from [2.47 to 3.35 GPA](http://clrsight.co/jh/8fi5l31nzs.png).
7. Much cleaner `open` code!
8. Converted several *slow* functional tests into *fast* unit tests with the same coverage.

# API Reference

We've created a comprehensive and always updated wiki with code examples, usage examples, and API reference.

### [ProMotion API Reference](https://github.com/clearsightstudio/ProMotion/wiki)

# Help

ProMotion is not only an easy DSL to get started. The community is very helpful and
welcoming to new RubyMotion developers. We don't mind newbie questions.

If you need help, feel free to open an issue on GitHub. If we don't respond within a day, tweet us a link to the issue -- sometimes we get busy.

# Contributing

See [CONTRIBUTING.md](https://github.com/clearsightstudio/ProMotion/blob/master/CONTRIBUTING.md).

## Primary Contributors

* Jamon Holmgren: [@jamonholmgren](https://twitter.com/jamonholmgren)
* Silas Matson: [@silasjmatson](https://twitter.com/silasjmatson)
* Mark Rickert: [@markrickert](https://twitter.com/markrickert)
* Ryan Linton: [@ryanlntn](https://twitter.com/ryanlntn)
* [Many others](https://github.com/clearsightstudio/ProMotion/graphs/contributors)
