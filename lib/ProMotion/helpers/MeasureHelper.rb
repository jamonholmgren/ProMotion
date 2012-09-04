module ProMotion
  class MeasureHelper
    class << self
      def content_height(view)
        height = 0
        view.subviews.each do |subView|
          y = subView.frame.origin.y
          h = subView.frame.size.height
          if (y + h) > height
            height = y + h
          end
        end
        height
      end
    end
  end
end