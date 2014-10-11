class FunctionalScreen < PM::Screen
  attr_accessor :button_was_triggered
  attr_accessor :on_back_fired

  title "Functional"

  def will_appear
    self.button_was_triggered = false
    add UILabel.alloc.initWithFrame([[ 10, 10 ], [ 300, 40 ]]), { text: "Label Here" }
  end

  def triggered_button
    self.button_was_triggered = true
  end

  def on_back
    @on_back_fired = true
  end
end
