class NavigationScreen < PM::Screen
  attr_accessor :on_back_fired

  def on_back
    self.on_back_fired = true
  end


end
