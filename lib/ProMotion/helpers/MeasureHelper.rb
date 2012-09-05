module ProMotion
  class MeasureHelper
    class << self
      def content_height(view)
        height = 0
        view.subviews.each do |sub_view|
          y = sub_view.frame.origin.y
          h = sub_view.frame.size.height
          if (y + h) > height
            height = y + h
          end
        end
        height
      end
    end
  end
end