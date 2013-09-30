class TestDelegateColored < TestDelegate
  status_bar false

  def on_load(app, options)
    open BasicScreen.new(nav_bar: true)
  end
end

class TestDelegateRed < TestDelegateColored
  tint_color UIColor.redColor
end

# Other colors

# class TestDelegateBlack < TestDelegateColored
#   tint_color UIColor.blackColor
# end
