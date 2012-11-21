module ProMotion
  class TableViewCell < UITableViewCell
    attr_accessor :image_size

    def layoutSubviews
      super

      if self.image_size
        f = self.imageView.frame
        size_inset_x = self.imageView.image.size.width - self.image_size
        size_inset_y = self.imageView.image.size.height - self.image_size
        self.imageView.frame = CGRectInset(f, size_inset_x, size_inset_y)
      end
    end
  end
end