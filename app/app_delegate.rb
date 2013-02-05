class AppDelegate < ProMotion::AppDelegateParent
  def on_load(app, options)
    open_tab_bar HomeScreen.new(nav_bar: true), TestScreen.new(nav_bar:true)
  end
end
