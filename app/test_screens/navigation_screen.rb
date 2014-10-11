class NavigationScreen < PM::Screen
  attr_reader :on_back_fired

  def on_back
    @on_back_fired = true
  end

end
