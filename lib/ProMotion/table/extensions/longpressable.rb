module ProMotion
  module Table
    module Longpressable
      def make_longpressable(params={})
        params = {
          min_duration: 1.0
        }.merge(params)

        long_press_gesture = UILongPressGestureRecognizer.alloc.initWithTarget(self, action:"on_long_press:")
        long_press_gesture.minimumPressDuration = params[:min_duration]
        long_press_gesture.delegate = self
        self.table_view.addGestureRecognizer(long_press_gesture)
      end

      def on_long_press(gesture)
        return unless gesture.state == UIGestureRecognizerStateBegan
        gesture_point = gesture.locationInView(table_view)
        index_path = table_view.indexPathForRowAtPoint(gesture_point)
        data_cell = self.promotion_table_data.cell(index_path: index_path)
        data_cell[:arguments] ||= {}
        trigger_action(data_cell[:long_press_action], data_cell[:arguments].merge({index_path: index_path})) if data_cell[:long_press_action]
      end
    end
  end
end
