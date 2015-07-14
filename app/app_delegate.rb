class AppDelegate < ProMotion::Delegate

  def on_load(app, options)
    open TestCollection2Screen.new(nav_bar: true)
  end

end
