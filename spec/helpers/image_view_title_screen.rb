class ImageViewTitleScreen < PM::Screen
  attr_accessor :button_was_triggered

  title UIImageView.alloc.initWithImage(UIImage.imageNamed('test.png'))

  def will_appear
    self.button_was_triggered = false
    add UILabel.alloc.initWithFrame([[ 10, 10 ], [ 300, 40 ]]),
      text: "Label Here"
  end

  def triggered_button
    self.button_was_triggered = true
  end
end
