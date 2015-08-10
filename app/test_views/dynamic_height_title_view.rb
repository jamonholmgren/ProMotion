class DynamicHeightTitleView < UIView
  attr_accessor :title

  def title=(t)
    # We're going to hijack this property setter in order to dynamically set
    # the size of the view's height.

    self.frame = CGRectMake(0,0, 320, t)
  end

  def height
    self.frame.size.height
  end
end
