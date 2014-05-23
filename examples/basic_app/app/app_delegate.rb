class AppDelegate < PM::Delegate

  status_bar true, animation: :none

  def on_load(app, options)
    open $h = HomeScreen.new(nav_bar: true)
  end
  
end
