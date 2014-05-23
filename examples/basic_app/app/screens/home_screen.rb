class HomeScreen < PM::Screen
  title "Home"

  def on_load
    set_nav_bar_button :right, title: "Cool", action: :triggered_button, style: :plain
  end

  def triggered_button
    PM.logger.info "Button pressed"
  end

end
