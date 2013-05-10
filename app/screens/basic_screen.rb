class BasicScreen < PM::Screen
  title "Basic"

  def on_init
    # Fires right after the screen is initialized
  end

  def on_load
    # Fires just before a screen is opened for the first time.
  end
  
  def will_appear
    # Fires every time the screen will appear
  end

  def on_appear
    # Fires just after the screen appears somewhere (after animations are complete)
  end

  def will_disappear
    # Fires just before the screen will disappear
  end

  def on_disappear
    # Fires after the screen is fully hidden
  end
end
