class TestDelegate < ProMotion::Delegate
  status_bar false

  attr_accessor :called_on_load, :called_will_load, :called_on_activate, 
    :called_will_deactivate, :called_on_enter_background, :called_will_enter_foreground,
    :called_on_unload, :called_should_select_tab, :called_on_tab_selected,
    :called_on_continue_user_activity, :user_activity, :restoration_handler

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

  def should_select_tab(vc)
    self.called_should_select_tab = true

    true
  end

  def on_tab_selected(vc)
    self.called_on_tab_selected = true
  end

  def on_continue_user_activity(params = {})
    self.called_on_continue_user_activity = true
    self.user_activity = params[:user_activity]
    self.restoration_handler = params[:restoration_handler]
  end
end
