module ProMotion
  class Element
    attr_accessor :view

    def initialize(with_view)
      self.view = with_view
      self
    end

    def remove
      self.view.removeFromSuperview
    end
  end
end