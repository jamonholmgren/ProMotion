module ProMotion::MotionTable
  module SectionedTable
    # @param [Array] Array of table data
    # @returns [UITableView] delegated to self
    def createTableViewFromData(data)
      setTableViewData data
      return tableView
    end

    def updateTableViewData(data)
      setTableViewData data
      self.tableView.reloadData
    end

    def setTableViewData(data)
      @mt_table_view_groups = data
    end

    def numberOfSectionsInTableView(tableView)
      if @mt_filtered
        return @mt_filtered_data.length if @mt_filtered_data
      else
        return @mt_table_view_groups.length if @mt_table_view_groups
      end
      0
    end

    # Number of cells
    def tableView(tableView, numberOfRowsInSection:section)
      return sectionAtIndex(section)[:cells].length if sectionAtIndex(section) && sectionAtIndex(section)[:cells]
      0
    end

    def tableView(tableView, titleForHeaderInSection:section)
      return sectionAtIndex(section)[:title] if sectionAtIndex(section) && sectionAtIndex(section)[:title]
    end

    # Set table_data_index if you want the right hand index column (jumplist)
    def sectionIndexTitlesForTableView(tableView)
      if self.respond_to?(:table_data_index)
        self.table_data_index 
      end
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)
      # Aah, magic happens here...

      dataCell = cellAtSectionAndIndex(indexPath.section, indexPath.row)
      return UITableViewCell.alloc.init unless dataCell
      dataCell[:cellStyle] ||= UITableViewCellStyleDefault
      dataCell[:cellIdentifier] ||= "Cell"
      cellIdentifier = dataCell[:cellIdentifier]
      dataCell[:cellClass] ||= PM::TableViewCell

      tableCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
      unless tableCell
        tableCell = dataCell[:cellClass].alloc.initWithStyle(dataCell[:cellStyle], reuseIdentifier:cellIdentifier)
        
        # Add optimizations here
        tableCell.layer.masksToBounds = true if dataCell[:masksToBounds]
        tableCell.backgroundColor = dataCell[:backgroundColor] if dataCell[:backgroundColor]
        tableCell.selectionStyle = dataCell[:selectionStyle] if dataCell[:selectionStyle]
        tableCell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
      end

      if dataCell[:cellClassAttributes]
        set_cell_attributes tableCell, dataCell[:cellClassAttributes]
      end
      
      if dataCell[:accessoryView]
        tableCell.accessoryView = dataCell[:accessoryView]
        tableCell.accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end

      if dataCell[:accessory] && dataCell[:accessory] == :switch
        switchView = UISwitch.alloc.initWithFrame(CGRectZero)
        switchView.addTarget(self, action: "accessoryToggledSwitch:", forControlEvents:UIControlEventValueChanged);
        switchView.on = true if dataCell[:accessoryDefault]
        tableCell.accessoryView = switchView
      end

      if dataCell[:subtitle]
        tableCell.detailTextLabel.text = dataCell[:subtitle]
        tableCell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end

      tableCell.selectionStyle = UITableViewCellSelectionStyleNone if dataCell[:no_select]

      if dataCell[:remoteImage]
        if tableCell.imageView.respond_to?("setImageWithURL:placeholderImage:")
          url = dataCell[:remoteImage][:url]
          url = NSURL.URLWithString(url) unless url.is_a?(NSURL)
          placeholder = dataCell[:remoteImage][:placeholder]
          placeholder = UIImage.imageNamed(placeholder) if placeholder.is_a?(String)

          tableCell.imageView.setImageWithURL(url, placeholderImage: placeholder)
          tableCell.imageView.layer.masksToBounds = true
          tableCell.imageView.layer.cornerRadius = dataCell[:remoteImage][:radius]
        else
          ProMotion::MotionTable::Console.log("ProMotion Warning: to use remoteImage with TableScreen you need to include the CocoaPod 'SDWebImage'.", withColor: MotionTable::Console::RED_COLOR)
        end
      elsif dataCell[:image]
        tableCell.imageView.layer.masksToBounds = true
        tableCell.imageView.image = dataCell[:image][:image]
        tableCell.imageView.layer.cornerRadius = dataCell[:image][:radius] if dataCell[:image][:radius]
      end

      if dataCell[:subViews]
        tag_number = 0
        dataCell[:subViews].each do |view|
          # Remove an existing view at that tag number
          tag_number += 1
          existing_view = tableCell.viewWithTag(tag_number)
          existing_view.removeFromSuperview if existing_view

          # Add the subview if it exists
          if view
            view.tag = tag_number
            tableCell.addSubview view
          end
        end
      end

      if dataCell[:details]
        tableCell.addSubview dataCell[:details][:image]
      end

      if dataCell[:styles] && dataCell[:styles][:textLabel] && dataCell[:styles][:textLabel][:frame]
        ui_label = false
        tableCell.contentView.subviews.each do |view|
          if view.is_a? UILabel
            ui_label = true
            view.text = dataCell[:styles][:textLabel][:text]
          end
        end

        unless ui_label == true
          label ||= UILabel.alloc.initWithFrame(CGRectZero)
          set_cell_attributes label, dataCell[:styles][:textLabel]
          tableCell.contentView.addSubview label
        end
        # hackery
        tableCell.textLabel.textColor = UIColor.clearColor
      else
        cell_title = dataCell[:title]
        cell_title ||= ""
        tableCell.textLabel.text = cell_title
      end

      return tableCell
    end

    def sectionAtIndex(index)
      if @mt_filtered
        @mt_filtered_data.at(index)
      else
        @mt_table_view_groups.at(index)
      end
    end

    def cellAtSectionAndIndex(section, index)
      return sectionAtIndex(section)[:cells].at(index) if sectionAtIndex(section) && sectionAtIndex(section)[:cells]
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      cell = cellAtSectionAndIndex(indexPath.section, indexPath.row)
      tableView.deselectRowAtIndexPath(indexPath, animated: true);
      cell[:arguments] ||= {}
      cell[:arguments][:cell] = cell if cell[:arguments].is_a?(Hash)
      triggerAction(cell[:action], cell[:arguments]) if cell[:action]
    end

    def accessoryToggledSwitch(switch)
      tableCell = switch.superview
      indexPath = tableCell.superview.indexPathForCell(tableCell)

      dataCell = cellAtSectionAndIndex(indexPath.section, indexPath.row)
      dataCell[:arguments] = {} unless dataCell[:arguments]
      dataCell[:arguments][:value] = switch.isOn if dataCell[:arguments].is_a? Hash
      
      triggerAction(dataCell[:accessoryAction], dataCell[:arguments]) if dataCell[:accessoryAction]

    end

    def triggerAction(action, arguments)
      if self.respond_to?(action)
        expectedArguments = self.method(action).arity
        if expectedArguments == 0
          self.send(action)
        elsif expectedArguments == 1 || expectedArguments == -1
          self.send(action, arguments)
        else
          ProMotion::MotionTable::Console.log("MotionTable warning: #{action} expects #{expectedArguments} arguments. Maximum number of required arguments for an action is 1.", withColor: MotionTable::Console::RED_COLOR)
        end
      else
        ProMotion::MotionTable::Console.log(self, actionNotImplemented: action)
      end
    end
  
    def set_cell_attributes(element, args = {})
      args.each do |k, v|
        if v.is_a? Hash
          v.each do
            sub_element = element.send("#{k}")
            set_cell_attributes(sub_element, v)
          end
          # v.each do |k2, v2|
          #   sub_element = element.send("#{k}")
          #   sub_element.send("#{k2}=", v2) if sub_element.respond_to?("#{k2}=")
          # end
        else
          element.send("#{k}=", v) if element.respond_to?("#{k}=")
        end
      end
      element
    end
  end
end