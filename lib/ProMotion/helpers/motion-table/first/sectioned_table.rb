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
      @tableView.reloadData
    end

    def setTableViewData(data)
      @mt_table_view_groups = data
    end

    def numberOfSectionsInTableView(tableView)
      return @mt_table_view_groups.length if @mt_table_view_groups
      0
    end

    # Number of cells
    def tableView(tableView, numberOfRowsInSection:section)
      return sectionAtIndex(section)[:cells].length
    end

    def tableView(tableView, titleForHeaderInSection:section)
      return sectionAtIndex(section)[:title]
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)
      dataCell = cellAtSectionAndIndex(indexPath.section, indexPath.row)
      
      cellIdentifier = "Cell"

      tableCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
      unless tableCell
        tableCell = UITableViewCell.alloc.initWithFrame(CGRectZero, reuseIdentifier:cellIdentifier)
        tableCell.accessoryView = dataCell[:accessoryView] if dataCell[:accessoryView]
        
        if dataCell[:accessory] && dataCell[:accessory] == :switch
          switchView = UISwitch.alloc.initWithFrame(CGRectZero)
          switchView.addTarget(self, action: "accessoryToggledSwitch:", forControlEvents:UIControlEventValueChanged);
          switchView.on = true if dataCell[:accessoryDefault]
          tableCell.accessoryView = switchView
        end
      end
      tableCell.text = dataCell[:title]
      return tableCell
    end

    def sectionAtIndex(index)
      @mt_table_view_groups.at(index)
    end

    def cellAtSectionAndIndex(section, index)
      return sectionAtIndex(section)[:cells].at(index)
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      cell = cellAtSectionAndIndex(indexPath.section, indexPath.row)
      tableView.deselectRowAtIndexPath(indexPath, animated: true);
      triggerAction(cell[:action], cell[:arguments]) if cell[:action]
    end

    def accessoryToggledSwitch(switch)
      tableCell = switch.superview
      indexPath = tableCell.superview.indexPathForCell(tableCell)

      dataCell = cellAtSectionAndIndex(indexPath.section, indexPath.row)
      dataCell[:arguments] = {} unless dataCell[:arguments]
      dataCell[:arguments][:value] = switch.isOn
      
      triggerAction(dataCell[:accessoryAction], dataCell[:arguments]) if dataCell[:accessoryAction]

    end

    def triggerAction(action, arguments)
      $stderr.puts "Action: #{action.to_s} and args #{arguments.to_s}"
      if self.respond_to?(action)
        expectedArguments = self.method(action).arity
        if expectedArguments == 0
          self.send(action)
        elsif expectedArguments == 1
          self.send(action, arguments)
        else
          MotionTable::Console.log("MotionTable warning: #{action} expects #{expectedArguments} arguments. Maximum number of required arguments for an action is 1.", withColor: MotionTable::Console::RED_COLOR)
        end
      else
        MotionTable::Console.log(self, actionNotImplemented: action)
      end
    end

  end
end