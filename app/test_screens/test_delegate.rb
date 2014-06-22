class TestDelegate < ProMotion::Delegate
  status_bar false

  attr_accessor :called_on_load, :called_will_load, :called_on_activate, :called_will_deactivate, :called_on_enter_background, :called_will_enter_foreground, :called_on_unload

  def on_load(app, options)
    self.called_on_load = true
  end

  def will_load(application, launch_options)
    self.called_will_load = true
  end

  def on_activate
    self.called_on_activate = true
  end

  def will_deactivate
    self.called_will_deactivate = true
  end

  def on_enter_background
    self.called_on_enter_background = true
  end

  def will_enter_foreground
    self.called_will_enter_foreground = true
  end

  def on_unload
    self.called_on_unload = true
  end

end
