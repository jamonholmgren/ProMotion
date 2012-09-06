class AppDelegate < ProMotion::AppDelegateParent
  def on_load(options)
    open_screen TestScreen, nav_bar: true
  end
end