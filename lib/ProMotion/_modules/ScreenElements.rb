module ProMotion
  module ScreenElements
    include ProMotion::ViewHelper
    
    def add_element(view, attrs = {})
      if attrs.length > 0
        set_attributes(view, attrs)
      end
      self.view_controller.view.addSubview(view)
      view
    end

    def remove_element(view)
      view.removeFromSuperview
      view = nil
      nil
    end

    def bounds
      return self.view_controller.view.bounds
    end
    
    def frame
      return self.view_controller.view.frame
    end

    def view
      return self.view_controller.view
    end
  end

