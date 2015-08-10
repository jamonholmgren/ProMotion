You can now enable live screen reloading in ProMotion!

When you run `pm_live_screens` in the REPL, ProMotion will watch your `app/screens` folder for changes and then intelligently reload screens for you. It'll even detect when a superclass is reloaded!

But alas, it's not entirely automatic. Here's a basic guide on how to use this powerful feature effectively.

## Set up screens to reload

Since it's impossible to know how every screen should be instantiated in every case, we're not able to completely reload the screen for you. Instead, we provide a hook for you to do teardown and rebuild.

```ruby
class MyScreen < PM::Screen
  def on_load
    my_view = UIView.new
    my_view.backgroundColor = UIColor.grayColor
    my_view.frame = [[ 100, 100 ], [ 100, 50 ]]
    self.view.addSubview my_view
    load_data
  end

  def load_data
    @some_live_data = { jamon: "Holmgren" }
  end

  def on_live_reload
    # teardown all views and data
    self.view.subviews.each(&:removeFromSuperview)
    @some_live_data = nil

    # rebuild all
    on_load
  end
end
```

However, if your screen does not have any extra setup besides adding views or loading the data source, then you can leave out `on_live_reload` and allow the base to tear down your views, and re-add for you!

Additionally, if your screen is created by another screen on a navigation controller stack (nav_bar), just go "back" to the previous screen and then re-open the current screen.

## REPL

In your REPL, type in the following:

```sh-session
> pm_live_screens interval: 1.5, debug: true
```

The `interval:` and `debug:` parameters are optional, and default to `0.5` and `false` respectively.

## Gotchas

Since you're providing your own teardown/rebuild code, we can't guarantee that the live reloaded screen will resemble a freshly built app. Make sure you rebuild the app entirely once in a while to be sure.



