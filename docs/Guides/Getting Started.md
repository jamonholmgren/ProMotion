ProMotion is designed to be as intuitive and Ruby-like as possible.

## Quick Setup (recommended)

Requirements:

* Licensed [RubyMotion](http://rubymotion.com) (2.29+ recommended)
* Xcode with command line tools installed
* Bundler (`gem install bundler`)
* CRuby 2.0.0+ (for executable)

```bash
gem install ProMotion #=> be sure to capitalize P and M here!
promotion new myapp
cd myapp
bundle
rake spec
rake
```

You should have a functioning ProMotion app!

## Manual Setup

Create a new RubyMotion project.

`motion create myapp`

Open the new folder in your favorite editor. Mine is Sublime, so I use `cd myapp; subl .` to open it.

Create a Gemfile and add the following lines:

```ruby
source "https://rubygems.org"

gem "rake"
gem "ProMotion", "~> 2.5"
```

Run `bundle` in Terminal to install ProMotion.

```
Fetching gem metadata from https://rubygems.org/....
Resolving dependencies...
Using rake 10.4.2
Using bundler 1.6.1
Using methadone 1.9.1
Using motion_print 1.2.0
Using ProMotion 2.4.2
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

Go into your app/app_delegate.rb file and replace *everything* with the following:

```ruby
class AppDelegate < PM::Delegate
  def on_load(app, options)
    open HomeScreen
  end
end
```

Create a folder in `/app` named `screens`. Create a file in that folder named `home_screen.rb`.

Now drop in this code in that file:

```ruby
class HomeScreen < PM::Screen
  title "Home"

  def on_load
    set_attributes self.view, {
      background_color: hex_color("#FFFFFF")
    }
  end
end
```

Run `rake`. You should now see the simulator open with your home screen and a navigation bar. Congrats!

### Next steps

* Read through the rest of the API documentation on the right sidebar.

Here are a few tutorials to follow.

* [Getting Started with MotionKit and ProMotion](http://jamonholmgren.com/getting-started-with-motionkit-and-promotion)
* [Building an ESPN App Using RubyMotion, ProMotion, and TDD](http://jamonholmgren.com/building-an-espn-app-using-rubymotion-promotion-and-tdd)


