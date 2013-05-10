module ProMotion::MotionTable
  module SectionedTable
    include ProMotion::ViewHelper
    
    def table_setup
      PM.logger.error "Missing #table_data method in TableScreen #{self.class.to_s}." unless self.respond_to?(:table_data)

      self.view = self.create_table_view_from_data(self.table_data)
      
      if self.class.respond_to?(:get_searchable) && self.class.get_searchable
        self.make_searchable(content_controller: self, search_bar: self.class.get_searchable_params)
      end
      if self.class.respond_to?(:get_refreshable) && self.class.get_refreshable
        if defined?(UIRefreshControl)
          self.make_refreshable(self.class.get_refreshable_params)
        else
          PM.logger.warn "To use the refresh control on < iOS 6, you need to include the CocoaPod 'CKRefreshControl'."
        end
      end
    end

    # @param [Array] Array of table data
    # @returns [UITableView] delegated to self
    def create_table_view_from_data(data)
      set_table_view_data data
      return table_view
    end
    alias :createTableViewFromData :create_table_view_from_data

    def update_table_view_data(data)
      set_table_view_data data
      self.table_view.reloadData
    end
    alias :updateTableViewData :update_table_view_data

    def set_table_view_data(data)
      @mt_table_view_groups = data
    end
    alias :setTableViewData :set_table_view_data

    def section_at_index(index)
      if @mt_filtered
        @mt_filtered_data.at(index)
      else
        @mt_table_view_groups.at(index)
      end
    end

    def cell_at_section_and_index(section, index)
      if section_at_index(section) && section_at_index(section)[:cells]
        return section_at_index(section)[:cells].at(index)
      end
    end
    alias :cellAtSectionAndIndex :cell_at_section_and_index

    def trigger_action(action, arguments)
      if self.respond_to?(action)
        expected_arguments = self.method(action).arity
        if expected_arguments == 0
          self.send(action)
        elsif expected_arguments == 1 || expected_arguments == -1
          self.send(action, arguments)
        else
          PM.logger.warn "#{action} expects #{expected_arguments} arguments. Maximum number of required arguments for an action is 1."
        end
      else
        PM.logger.info "Action not implemented: #{action.to_s}"
      end
    end

    def accessory_toggled_switch(switch)
      table_cell = switch.superview
      index_path = table_cell.superview.indexPathForCell(table_cell)

      data_cell = cell_at_section_and_index(index_path.section, index_path.row)
      data_cell[:arguments] = {} unless data_cell[:arguments]
      data_cell[:arguments][:value] = switch.isOn if data_cell[:arguments].is_a? Hash
      data_cell[:accessory_action] ||= data_cell[:accessoryAction] # For legacy support

      trigger_action(data_cell[:accessory_action], data_cell[:arguments]) if data_cell[:accessory_action]
    end

    ########## Cocoa touch methods, leave as-is #################
    def numberOfSectionsInTableView(table_view)
      if @mt_filtered
        return @mt_filtered_data.length if @mt_filtered_data
      else
        return @mt_table_view_groups.length if @mt_table_view_groups
      end
      0
    end

    # Number of cells
    def tableView(table_view, numberOfRowsInSection:section)
      return section_at_index(section)[:cells].length if section_at_index(section) && section_at_index(section)[:cells]
      0
    end

    def tableView(table_view, titleForHeaderInSection:section)
      return section_at_index(section)[:title] if section_at_index(section) && section_at_index(section)[:title]
    end

    # Set table_data_index if you want the right hand index column (jumplist)
    def sectionIndexTitlesForTableView(table_view)
      if self.respond_to?(:table_data_index)
        self.table_data_index
      end
    end

    def remap_data_cell(data_cell)
      # Re-maps legacy data cell calls
      mappings = {
        cell_style: :cellStyle,
        cell_identifier: :cellIdentifier,
        cell_class: :cellClass,
        masks_to_bounds: :masksToBounds,
        background_color: :backgroundColor,
        selection_style: :selectionStyle,
        cell_class_attributes: :cellClassAttributes,
        accessory_view: :accessoryView,
        accessory_type: :accessoryType,
        accessory_checked: :accessoryDefault,
        remote_image: :remoteImage,
        subviews: :subViews
      }
      mappings.each_pair do |n, old|
        if data_cell[old]
          warn "[DEPRECATION] `:#{old}` is deprecated in TableScreens. Use `:#{n}`"
          data_cell[n] = data_cell[old]
        end
      end
      if data_cell[:styles] && data_cell[:styles][:textLabel]
        warn "[DEPRECATION] `:textLabel` is deprecated in TableScreens. Use `:label`"
        data_cell[:styles][:label] = data_cell[:styles][:textLabel]
      end
      data_cell
    end

    def tableView(table_view, cellForRowAtIndexPath:index_path)
      data_cell = cell_at_section_and_index(index_path.section, index_path.row)
      return UITableViewCell.alloc.init unless data_cell

      data_cell = self.remap_data_cell(data_cell)

      data_cell[:cell_style] ||= UITableViewCellStyleDefault
      data_cell[:cell_identifier] ||= "Cell"
      cell_identifier = data_cell[:cell_identifier]
      data_cell[:cell_class] ||= ProMotion::TableViewCell

      table_cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier)
      unless table_cell
        table_cell = data_cell[:cell_class].alloc.initWithStyle(data_cell[:cell_style], reuseIdentifier:cell_identifier)

        # Add optimizations here
        table_cell.layer.masksToBounds = true if data_cell[:masks_to_bounds]
        table_cell.backgroundColor = data_cell[:background_color] if data_cell[:background_color]
        table_cell.selectionStyle = data_cell[:selection_style] if data_cell[:selection_style]
        table_cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
      end

      if data_cell[:cell_class_attributes]
        set_attributes table_cell, data_cell[:cell_class_attributes]
      end

      if data_cell[:accessory_view]
        table_cell.accessoryView = data_cell[:accessory_view]
        table_cell.accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end

      if data_cell[:accessory_type]
        table_cell.accessoryType = data_cell[:accessory_type]
      end

      if data_cell[:accessory] && data_cell[:accessory] == :switch
        switch_view = UISwitch.alloc.initWithFrame(CGRectZero)
        switch_view.addTarget(self, action: "accessory_toggled_switch:", forControlEvents:UIControlEventValueChanged)
        switch_view.on = true if data_cell[:accessory_checked]
        table_cell.accessoryView = switch_view
      end

      if data_cell[:subtitle]
        table_cell.detailTextLabel.text = data_cell[:subtitle]
        table_cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end

      table_cell.selectionStyle = UITableViewCellSelectionStyleNone if data_cell[:no_select]

      if data_cell[:remote_image]
        if table_cell.imageView.respond_to?("setImageWithURL:placeholderImage:")
          url = data_cell[:remote_image][:url]
          url = NSURL.URLWithString(url) unless url.is_a?(NSURL)
          placeholder = data_cell[:remote_image][:placeholder]
          placeholder = UIImage.imageNamed(placeholder) if placeholder.is_a?(String)

          table_cell.image_size = data_cell[:remote_image][:size] if data_cell[:remote_image][:size] && table_cell.respond_to?("image_size=")
          table_cell.imageView.setImageWithURL(url, placeholderImage: placeholder)
          table_cell.imageView.layer.masksToBounds = true
          table_cell.imageView.layer.cornerRadius = data_cell[:remote_image][:radius] if data_cell[:remote_image].has_key?(:radius)
        else
          PM.logger.error "ProMotion Warning: to use remote_image with TableScreen you need to include the CocoaPod 'SDWebImage'."
        end
      elsif data_cell[:image]
        table_cell.imageView.layer.masksToBounds = true
        table_cell.imageView.image = data_cell[:image][:image]
        table_cell.imageView.layer.cornerRadius = data_cell[:image][:radius] if data_cell[:image][:radius]
      end

      if data_cell[:subviews]
        tag_number = 0
        data_cell[:subviews].each do |view|
          # Remove an existing view at that tag number
          tag_number += 1
          existing_view = table_cell.viewWithTag(tag_number)
          existing_view.removeFromSuperview if existing_view

          # Add the subview if it exists
          if view
            view.tag = tag_number
            table_cell.addSubview view
          end
        end
      end

      if data_cell[:details]
        table_cell.addSubview data_cell[:details][:image]
      end

      if data_cell[:styles] && data_cell[:styles][:label] && data_cell[:styles][:label][:frame]
        ui_label = false
        table_cell.contentView.subviews.each do |view|
          if view.is_a? UILabel
            ui_label = true
            view.text = data_cell[:styles][:label][:text]
          end
        end

        unless ui_label == true
          label ||= UILabel.alloc.initWithFrame(CGRectZero)
          set_attributes label, data_cell[:styles][:label]
          table_cell.contentView.addSubview label
        end
        # hackery
        table_cell.textLabel.textColor = UIColor.clearColor
      else
        cell_title = data_cell[:title]
        cell_title ||= ""
        table_cell.textLabel.text = cell_title
      end

      return table_cell
    end

    def tableView(tableView, heightForRowAtIndexPath:index_path)
      cell = cell_at_section_and_index(index_path.section, index_path.row)
      if cell[:height]
        cell[:height].to_f
      else
        tableView.rowHeight
      end
    end

    def tableView(table_view, didSelectRowAtIndexPath:index_path)
      cell = cell_at_section_and_index(index_path.section, index_path.row)
      table_view.deselectRowAtIndexPath(index_path, animated: true)
      cell[:arguments] ||= {}
      cell[:arguments][:cell] = cell if cell[:arguments].is_a?(Hash)
      trigger_action(cell[:action], cell[:arguments]) if cell[:action]
    end
  end
end