class DynamicHeightTitleView < UIView
  def on_load
    @height = 12.0
  end

  def title=(t)
    # Do something here
  end

  def height
    @height
  end
end


class DynamicHeightTitleView40 < DynamicHeightTitleView
  def on_load
    @height = 40.0
  end
end

class DynamicHeightTitleView121 < DynamicHeightTitleView
  def on_load
    @height = 121.0
  end
end
