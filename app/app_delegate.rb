class AppDelegate < ProMotion::Delegate

  def on_load(app, options)
    open TestCollectionScreen.new(nav_bar: true)
  end

end
