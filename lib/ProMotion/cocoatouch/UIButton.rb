class UIButton
  def background_images(*images)
    images.each do |image|
      if image[:image].nil? or image[:state].nil?
        PM.logger.error "Error: background_images should be an array with hashes such as [{image: a_UIImage_Instance, state: UIControlStateSelected}]"
        next
      end
      self.setBackgroundImage(image[:image], forState: image[:state])
    end
  end

  def targets(*array_targets)
    array_targets.each do |t|
      if t[:target].nil? or t[:action].nil? or t[:event].nil?
        PM.logger.error "Error: targets should be an array with hashes such as [{target: self, action: :button_clicked, event: UIControlEventTouchUpInside}]"
        next
      end
      self.addTarget(t[:target], action: t[:action], forControlEvents: t[:event])
    end
  end
end
