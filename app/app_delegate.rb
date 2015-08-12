class AppDelegate < ProMotion::Delegate

  def on_load(app, options)
    open UIImageTitleScreen.new(nav_bar: true)
  end

end
