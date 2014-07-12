class AppDelegate < ProMotion::Delegate

  def on_load(app, options)
    open BasicScreen.new(nav_bar: true)
  end

end
