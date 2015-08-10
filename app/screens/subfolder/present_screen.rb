class PresentScreen < PM::Screen
  attr_accessor :will_present_fired, :on_present_fired, :will_dismiss_fired, :on_dismiss_fired

  def will_present
    self.will_present_fired = true
  end

  def on_present
    self.on_present_fired = true
  end

  def will_dismiss
    self.will_dismiss_fired = true
  end

  def on_dismiss
    self.on_dismiss_fired = true
  end

  def reset
    self.will_present_fired = false
    self.on_present_fired = false
    self.will_dismiss_fired = false
    self.on_dismiss_fired = false
  end
end
