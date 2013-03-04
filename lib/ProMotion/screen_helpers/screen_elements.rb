module ProMotion
  module ScreenElements
    include ProMotion::ViewHelper
    
    def add(v, attrs = {})
      if attrs && attrs.length > 0
        set_attributes(v, attrs)
      end
      self.view.addSubview(v)
      v
    end
    alias :add_element :add
    alias :add_view :add

    def remove(v)
      v.removeFromSuperview
      v = nil
    end
    alias :remove_element :remove
    alias :remove_view :remove

    def bounds
      return self.view.bounds
    end
    
    def frame
      return self.view.frame
    end

    def content_height(view)
      height = 0
      view.subviews.each do |subview|
        next if subview.isHidden
        y = subview.frame.origin.y
        h = subview.frame.size.height
        if (y + h) > height
          height = y + h
        end
      end
      height
    end
  end
end
