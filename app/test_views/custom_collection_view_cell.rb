class CustomCollectionViewCell < PM::CollectionViewCell

  def setup(data_cell, screen)
    super.tap do
      @label.text = data_cell[:title]
    end
  end

  def on_created
    self.backgroundColor = UIColor.colorWithRed(rand(255) / 255.0,
                                                green: rand(255) / 255.0,
                                                blue:  rand(255) / 255.0,
                                                alpha: 1.0)

    @label               = UILabel.new
    @label.frame         = [[0, 0], [40, 40]]
    @label.textAlignment = NSTextAlignmentCenter
    self.contentView.addSubview(@label)
  end

  def on_reused
  end

end