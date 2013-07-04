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

## Apps Built With ProMotion

[View apps built with ProMotion (feel free to submit yours!)](https://github.com/clearsightstudio/ProMotion/wiki/Apps-built-on-ProMotion)

# Getting Started

Check out our new [Getting Started Guide](https://github.com/clearsightstudio/ProMotion/wiki/Getting-Started-Guide) in the wiki!

# What's New?

## Version 1.0

* TODO

# Usage

Check out the [Basic Usage Examples](https://github.com/clearsightstudio/ProMotion/wiki/Basic-Usage-Examples) in the wiki for usage examples.

# API Reference

We've created a comprehensive and always updated wiki with code examples, usage examples, and API reference.

### [ProMotion API Reference](https://github.com/clearsightstudio/ProMotion/wiki/_pages)

# Help

If you need help, feel free to ping me on twitter [@jamonholmgren](http://twitter.com/jamonholmgren)
or open an issue on GitHub. Opening an issue is usually the best and we respond to those pretty quickly.

# Contributing

I'm very open to ideas. Tweet me with your ideas or open a ticket (I don't mind!)
and let's discuss. **It's a good idea to run your idea by the committers before creating
a pull request.** We'll always consider your ideas carefully but not all ideas will be
incorporated.

## Working on Features

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

