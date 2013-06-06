module ProMotion
  module TableViewCellModule
    include ViewHelper

    attr_accessor :data_cell

    def setup(data_cell)
      self.data_cell = data_cell

      # TODO: Some of these need to go away. Unnecessary overhead.
      set_cell_attributes
      set_background_color
      set_class_attributes
      set_accessory_view
      set_subtitle
      set_image
      set_remote_image
      set_subviews
      set_details
      set_styles
      set_selection_style

      self
    end

    def set_cell_attributes
      data_cell_attributes = data_cell.dup
      [:image, :accessory_action].each { |k| data_cell_attributes.delete(k) }
      set_attributes self, data_cell_attributes
      self
    end

    def set_background_color
      self.backgroundView = UIView.new.tap{|v| v.backgroundColor = data_cell[:background_color]} if data_cell[:background_color]
    end

    def set_class_attributes
      if data_cell[:cell_class_attributes]
        PM.logger.deprecated "`cell_class_attributes` is deprecated. Just add the attributes you want to set right into your cell hash."
        set_attributes self, data_cell[:cell_class_attributes]
      end
      self
    end

    def set_accessory_view
      data_cell[:accessory] ||= data_cell[:accessory_view]

      if data_cell[:accessory] == :switch
        switch_view = UISwitch.alloc.initWithFrame(CGRectZero)
        switch_view.addTarget(cell_table_view, action: "accessory_toggled_switch:", forControlEvents:UIControlEventValueChanged)
        switch_view.on = true if data_cell[:accessory_checked]
        self.accessoryView = switch_view
      elsif data_cell[:accessory]
        self.accessoryView = data_cell[:accessory]
        self.accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end

      self
    end

    def set_subtitle
      if data_cell[:subtitle] && self.detailTextLabel
        self.detailTextLabel.text = data_cell[:subtitle]
        self.detailTextLabel.backgroundColor = UIColor.clearColor
        self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end
      self
    end

    def set_remote_image
      if data_cell[:remote_image]
        if self.imageView.respond_to?("setImageWithURL:placeholderImage:")
          url = data_cell[:remote_image][:url]
          url = NSURL.URLWithString(url) unless url.is_a?(NSURL)
          placeholder = data_cell[:remote_image][:placeholder]
          placeholder = UIImage.imageNamed(placeholder) if placeholder.is_a?(String)

          self.image_size = data_cell[:remote_image][:size] if data_cell[:remote_image][:size] && self.respond_to?("image_size=")
          self.imageView.setImageWithURL(url, placeholderImage: placeholder)
          self.imageView.layer.masksToBounds = true
          self.imageView.layer.cornerRadius = data_cell[:remote_image][:radius] if data_cell[:remote_image].has_key?(:radius)
        else
          PM.logger.error "ProMotion Warning: to use remote_image with TableScreen you need to include the CocoaPod 'SDWebImage'."
        end
      end
      self
    end

    def set_image
      if data_cell[:image]

        cell_image = data_cell[:image].is_a?(Hash) ? data_cell[:image][:image] : data_cell[:image]
        cell_image = UIImage.imageNamed(cell_image) if cell_image.is_a?(String)

        self.imageView.layer.masksToBounds = true
        self.imageView.image = cell_image
        self.imageView.layer.cornerRadius = data_cell[:image][:radius] if data_cell[:image].is_a?(Hash) && data_cell[:image][:radius]
      end
      self
    end

    def set_subviews
      tag_number = 0
      Array(data_cell[:subviews]).each do |view|
        # Remove an existing view at that tag number
        tag_number += 1
        existing_view = self.viewWithTag(tag_number)
        existing_view.removeFromSuperview if existing_view

        # Add the subview if it exists
        if view
          view.tag = tag_number
          self.addSubview view
        end
      end
      self
    end

    def set_details
      if data_cell[:details]
        self.addSubview data_cell[:details][:image]
      end
      self
    end

    def set_styles
      if data_cell[:styles] && data_cell[:styles][:label] && data_cell[:styles][:label][:frame]
        ui_label = false
        self.contentView.subviews.each do |view|
          if view.is_a? UILabel
            ui_label = true
            view.text = data_cell[:styles][:label][:text]
          end
        end

        unless ui_label == true
          label ||= UILabel.alloc.initWithFrame(CGRectZero)
          set_attributes label, data_cell[:styles][:label]
          self.contentView.addSubview label
        end

        # TODO: What is this and why is it necessary?
        self.textLabel.textColor = UIColor.clearColor
      else
        cell_title = data_cell[:title]
        cell_title ||= ""
        self.textLabel.backgroundColor = UIColor.clearColor
        self.textLabel.text = cell_title
      end

      self
    end

    def set_selection_style
      self.selectionStyle = UITableViewCellSelectionStyleNone if data_cell[:no_select]
    end

    def cell_table_view
      @cell_tableview ||= begin
        # iterate up the view hierarchy to find the table containing this cell/view
        this_view = self.superview
        while this_view != nil do
            return this_view if this_view.is_a? UITableView
            this_view = this_view.superview
        end
        nil # this view is not within a tableView
      end
    end
  end
end
