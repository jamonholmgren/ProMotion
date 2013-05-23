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
end
