class HomeScreen < ProMotion::Screen
  title "Home Screen"
  
  def on_load
    @label = add_view UILabel.alloc.initWithFrame(CGRectZero), {
      text: "Working...",
      font: UIFont.systemFontOfSize(18),
      textColor: UIColor.blackColor
    }

    self.view.backgroundColor = UIColor.whiteColor
    self.set_nav_bar_right_button "Test", action: :test_it
    
    title "Updated home screen"
  end

  def on_appear
  end

  def test_it
    open TestScreen
  end
end