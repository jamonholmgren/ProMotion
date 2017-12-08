module ProMotion
  module TableViewCellModule
    include Styling

    attr_accessor :data_cell, :table_screen

    def setup(data_cell, screen)
      self.table_screen = WeakRef.new(screen)
      self.data_cell = data_cell

      check_deprecated_styles
      set_styles
      set_title
      set_subtitle
      set_image
      set_remote_image
      set_accessory_view
      set_selection_style
      set_accessory_type
    end

    def layoutSubviews
      super
      return unless data_cell

      # Support changing sizes of the image view
      if (data_cell[:image] && data_cell[:image].is_a?(Hash) && data_cell[:image][:size])
        self.imageView.bounds = CGRectMake(0, 0, data_cell[:image][:size], data_cell[:image][:size]);
      elsif (data_cell[:remote_image] && data_cell[:remote_image][:size])
        self.imageView.bounds = CGRectMake(0, 0, data_cell[:remote_image][:size], data_cell[:remote_image][:size]);
      end
    end

  protected

    # TODO: Remove this in ProMotion 2.1. Just for migration purposes.
    def check_deprecated_styles
      whitelist = [ :title, :subtitle, :image, :remote_image, :accessory, :selection_style, :action, :long_press_action, :arguments, :cell_style, :cell_class, :cell_identifier, :editing_style, :moveable, :search_text, :keep_selection, :height, :accessory_type, :style, :properties, :searchable ]
      if (data_cell.keys - whitelist).length > 0
        mp "In #{self.table_screen.class.to_s}#table_data, you should set :#{(data_cell.keys - whitelist).join(", :")} in a `properties:` hash. See TableScreen documentation.", force_color: :yellow
      end
    end

    def set_styles
      data_cell[:properties] ||= data_cell[:style] || data_cell[:styles]
      set_attributes self, data_cell[:properties] if data_cell[:properties]
    end

    def set_title
      set_attributed_text(self.textLabel, data_cell[:title]) if data_cell[:title]
    end

    def set_subtitle
      return unless data_cell[:subtitle] && self.detailTextLabel
      set_attributed_text(self.detailTextLabel, data_cell[:subtitle])
      self.detailTextLabel.backgroundColor = UIColor.clearColor
      self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
    end

    def set_remote_image
      return unless data_cell[:remote_image] && (sd_web_image? || jm_image_cache?)

      self.imageView.image = remote_placeholder

      if sd_web_image?
        if SDWebImageManager.sharedManager.respond_to?('downloadWithURL:options:progress:completed:')
          # SDWebImage 3.x
          @remote_image_operation = SDWebImageManager.sharedManager.downloadWithURL(data_cell[:remote_image][:url].to_url,
            options:SDWebImageRefreshCached,
            progress:nil,
            completed: -> image, error, cacheType, finished {
              self.imageView.image = image unless image.nil?
              self.setNeedsLayout
          })
        else
          # SDWebImage 4.x
          @remote_image_operation = SDWebImageManager.sharedManager.loadImageWithURL(data_cell[:remote_image][:url].to_url,
            options:SDWebImageRefreshCached | SDWebImageScaleDownLargeImages,
            progress:nil,
            completed: -> image, imageData, error, cacheType, finished, imageURL {
              self.imageView.image = image unless image.nil?
              self.setNeedsLayout
          })
        end
      elsif jm_image_cache?
        mp "'JMImageCache' is known to have issues with ProMotion. Please consider switching to 'SDWebImage'. 'JMImageCache' support will be deprecated in the next major version.", force_color: :yellow
        JMImageCache.sharedCache.imageForURL(data_cell[:remote_image][:url].to_url, completionBlock:proc { |downloaded_image|
          self.imageView.image = downloaded_image
          self.setNeedsLayout
        })
      else
        mp "To use remote_image with TableScreen you need to include the CocoaPod 'SDWebImage'.", force_color: :red
      end

      self.imageView.layer.masksToBounds = true
      self.imageView.layer.cornerRadius = data_cell[:remote_image][:radius] if data_cell[:remote_image][:radius]
      self.imageView.contentMode = map_content_mode_symbol(data_cell[:remote_image][:content_mode]) if data_cell[:remote_image][:content_mode]
    end

    def set_image
      return unless data_cell[:image]
      cell_image = data_cell[:image].is_a?(Hash) ? data_cell[:image][:image] : data_cell[:image]
      cell_image = UIImage.imageNamed(cell_image) if cell_image.is_a?(String)
      self.imageView.layer.masksToBounds = true
      self.imageView.image = cell_image
      self.imageView.layer.cornerRadius = data_cell[:image][:radius] if data_cell[:image].is_a?(Hash) && data_cell[:image][:radius]
    end

    def set_accessory_view
      return self.accessoryView = nil unless data_cell[:accessory] && data_cell[:accessory][:view]
      if data_cell[:accessory][:view] == :switch
        self.accessoryView = switch_view
      else
        if data_cell[:accessory][:view].superview && data_cell[:accessory][:view].superview.is_a?(UITableViewCell)
          data_cell[:accessory][:view].superview.accessoryView = nil # Fix for issue #586
        end
        self.accessoryView = data_cell[:accessory][:view]
        self.accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end
    end

    def set_selection_style
      self.selectionStyle = map_selection_style_symbol(data_cell[:selection_style]) if data_cell[:selection_style]
    end

    def set_accessory_type
      self.accessoryType = map_accessory_type_symbol(data_cell[:accessory_type]) if data_cell[:accessory_type]
    end

    def prepareForReuse
      super
      if @remote_image_operation && @remote_image_operation.respond_to?(:cancel)
        @remote_image_operation.cancel
        @remote_image_operation = nil
      end
      self.send(:prepare_for_reuse) if self.respond_to?(:prepare_for_reuse)
    end

  private

    def sd_web_image?
      return false if RUBYMOTION_ENV == 'test'
      !!defined?(SDWebImageManager)
    end

    def jm_image_cache?
      return false if RUBYMOTION_ENV == 'test'
      !!defined?(JMImageCache)
      false
    end

    def remote_placeholder
      UIImage.imageNamed(data_cell[:remote_image][:placeholder]) if data_cell[:remote_image][:placeholder].is_a?(String)
    end

    def switch_view
      switch = UISwitch.alloc.initWithFrame(CGRectZero)
      switch.setAccessibilityLabel(data_cell[:accessory][:accessibility_label] || data_cell[:title])
      switch.addTarget(self.table_screen, action: "accessory_toggled_switch:", forControlEvents:UIControlEventValueChanged)
      switch.on = !!data_cell[:accessory][:value]
      switch
    end

    def set_attributed_text(label, text)
      text.is_a?(NSAttributedString) ? label.attributedText = text : label.text = text
    end

    def map_content_mode_symbol(symbol)
      {
        scale_to_fill:     UIViewContentModeScaleToFill,
        scale_aspect_fit:  UIViewContentModeScaleAspectFit,
        scale_aspect_fill: UIViewContentModeScaleAspectFill,
        mode_redraw:       UIViewContentModeRedraw
      }[symbol] || symbol
    end

    def map_selection_style_symbol(symbol)
      {
        none:     UITableViewCellSelectionStyleNone,
        blue:     UITableViewCellSelectionStyleBlue,
        gray:     UITableViewCellSelectionStyleGray,
        default:  UITableViewCellSelectionStyleDefault
      }[symbol] || symbol
    end

    def map_accessory_type_symbol(symbol)
      {
        none:                 UITableViewCellAccessoryNone,
        disclosure_indicator: UITableViewCellAccessoryDisclosureIndicator,
        disclosure_button:    UITableViewCellAccessoryDetailDisclosureButton,
        checkmark:            UITableViewCellAccessoryCheckmark,
        detail_button:        UITableViewCellAccessoryDetailButton
      }[symbol] || symbol
    end
  end
end
