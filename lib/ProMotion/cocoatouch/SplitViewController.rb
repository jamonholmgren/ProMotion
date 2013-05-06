class SplitViewController < UISplitViewController
  def master_screen
    s = self.viewControllers.first
    s.respond_to?(:visibleViewController) ? s.visibleViewController : s
  end
  def detail_screen
    s = self.viewControllers.last
    s.respond_to?(:visibleViewController) ? s.visibleViewController : s
  end
  def master_screen=(s)
    self.viewControllers = [s.main_controller, self.viewControllers.last]
  end
  def detail_screen=(s)
    # set the button from the old detail screen to the new one
    button = detail_screen.navigationItem.leftBarButtonItem
    s.navigationItem.leftBarButtonItem = button

    self.viewControllers = [self.viewControllers.first, s.main_controller]
  end
  def screens=(s_array)
    self.viewControllers = s_array
  end
end