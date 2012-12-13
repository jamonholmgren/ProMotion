class AppDelegate < ProMotion::AppDelegateParent
  def on_load(app, options)
    open_screen TestScreen.new(nav_bar: true)
  end
end