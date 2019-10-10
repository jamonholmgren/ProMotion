class FuncNavController < PM::NavigationController; end

class FunctionalScreen < PM::Screen
  attr_accessor :button_was_triggered
  attr_accessor :button2_was_triggered
  attr_accessor :on_back_fired

  title "Functional"
  nav_bar true, {
    nav_controller: FuncNavController,
    toolbar: true,
    transition_style: UIModalTransitionStyleCrossDissolve,
    presentation_style: UIModalPresentationFormSheet,
  }

  def will_appear
    self.button_was_triggered = false
    self.button2_was_triggered = false
    add UILabel.alloc.initWithFrame([[ 10, 10 ], [ 300, 40 ]]), { text: "Label Here" }
  end

  def triggered_button
    self.button_was_triggered = true
  end

  def triggered_button2
    self.button2_was_triggered = true
  end

  def on_back
    @on_back_fired = true
  end
end
