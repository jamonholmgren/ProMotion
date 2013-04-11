class SplitViewController < UISplitViewController

  attr_accessor :bar_button_item, :popover_controller
  
  def main_controller
    self
  end
end