class HomeScreen < ProMotion::Screen
  title "Home Screen"
  
  def on_load
    @label = add_view UILabel.alloc.initWithFrame(CGRectMake(5, 5, 20, 20)), {
      text: "This is awesome!",
      font: UIFont.UIFont.systemFontOfSize(18)
    }
  end
end