class HomeScreen < ProMotion::Screen

  title "Home"

  def on_load
    set_nav_bar_button :left, title: "Save", action: :save_something, type: :done
    set_nav_bar_button :right, image: UIImage.imageNamed("list.png"), action: :return_to_some_other_screen, type: :plain
  end

  def on_return(args={})
  end

  def subview_styles
    {
      background_color: UIColor.greenColor
    }
  end

end
