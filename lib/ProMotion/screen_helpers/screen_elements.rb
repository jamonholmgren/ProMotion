module ProMotion
  module ScreenElements
    include ProMotion::ViewHelper

    def add(element, attrs = {})
      add_to self.view, element, attrs
    end
    alias :add_element :add
    alias :add_view :add

    def remove(element)
      element.removeFromSuperview
      element = nil
    end
    alias :remove_element :remove
    alias :remove_view :remove
    
    def add_to(parent_element, element, attrs = {})
      if attrs && attrs.length > 0
        set_attributes(element, attrs)
        set_easy_attributes(parent_element, element, attrs)
      end
      parent_element.addSubview element
      element
    end

    def bounds
      return self.view.bounds
    end

    def frame
      return self.view.frame
    end

  end
end
