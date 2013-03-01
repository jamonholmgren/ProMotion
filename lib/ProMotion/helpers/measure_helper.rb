module ProMotion
  class MeasureHelper
    class << self
      def content_height(view)
        warn "[DEPRECATION] `MeasureHelper.content_height` is deprecated. Include the module `ScreenElements` to get access to this method (already included in Screen)."

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
end