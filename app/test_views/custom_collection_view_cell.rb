class CustomCollectionViewCell < PM::CollectionViewCell

  def setup(data_cell, screen)
    super.tap do
      @label.text          = data_cell[:title]
      self.backgroundColor = data_cell[:background_color]
    end
  end

  def on_created
    @label               = UILabel.new
    @label.frame         = [[0, 0], [40, 40]]
    @label.textAlignment = NSTextAlignmentCenter
    self.contentView.addSubview(@label)
  end

  def on_reused
  end

end
