class DynamicHeightFooterView < UIView
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


class DynamicHeightFooterView40 < DynamicHeightFooterView
  def on_load
    @height = 40.0
  end
end

class DynamicHeightFooterView121 < DynamicHeightFooterView
  def on_load
    @height = 121.0
  end
end
