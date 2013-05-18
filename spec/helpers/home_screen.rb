class HomeScreen < ProMotion::Screen

  title "Home"

  def on_load
    set_nav_bar_right_button "Save", action: :save_something, type: UIBarButtonItemStyleDone
    set_nav_bar_left_button UIImage.imageNamed("list.png"), action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
  end

  def on_return(args={})
  end

end
