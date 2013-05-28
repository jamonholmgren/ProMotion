module ProMotion
  module Table
    include ProMotion::ViewHelper

    def table_setup
      check_table_data
      set_up_table_view
      set_up_searchable
      set_up_refreshable
    end
    
    def check_table_data
      PM.logger.error "Missing #table_data method in TableScreen #{self.class.to_s}." unless self.respond_to?(:table_data)
    end
    
    def set_up_table_view
      self.view = self.create_table_view_from_data(self.table_data)
    end
    
    def set_up_searchable
      if self.class.respond_to?(:get_searchable) && self.class.get_searchable
        self.make_searchable(content_controller: self, search_bar: self.class.get_searchable_params)
      end
    end
    
    def set_up_refreshable
      if self.class.respond_to?(:get_refreshable) && self.class.get_refreshable
        if defined?(UIRefreshControl)
          self.make_refreshable(self.class.get_refreshable_params)
        else
          PM.logger.warn "To use the refresh control on < iOS 6, you need to include the CocoaPod 'CKRefreshControl'."
        end
      end
    end

    def create_table_view_from_data(data)
      @promotion_table_data = TableData.new(data, table_view)
      table_view
    end

    def update_table_view_data(data)
      @promotion_table_data.data = data
      table_view.reloadData
    end

    # Methods to retrieve data

    def section_at_index(index)
      @promotion_table_data.section(index)
    end

    def cell_at_section_and_index(section, index)
      @promotion_table_data.cell(section: section, index: index)
    end

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

    ########## Cocoa touch methods #################
    def numberOfSectionsInTableView(table_view)
      return Array(@promotion_table_data.data).length
    end

    # Number of cells
    def tableView(table_view, numberOfRowsInSection:section)
      return @promotion_table_data.section_length(section)
      0
    end

    def tableView(table_view, titleForHeaderInSection:section)
      return section_at_index(section)[:title] if section_at_index(section) && section_at_index(section)[:title]
    end

    # Set table_data_index if you want the right hand index column (jumplist)
    def sectionIndexTitlesForTableView(table_view)
      self.table_data_index if self.respond_to?(:table_data_index)
    end

    def tableView(table_view, cellForRowAtIndexPath:index_path)
      @promotion_table_data.table_view_cell(index_path: index_path)
    end

    def tableView(table_view, heightForRowAtIndexPath:index_path)
      (@promotion_table_data.cell(index_path: index_path)[:height] || table_view.rowHeight).to_f
    end

    def tableView(table_view, didSelectRowAtIndexPath:index_path)
      cell = @promotion_table_data.cell(index_path: index_path)
      table_view.deselectRowAtIndexPath(index_path, animated: true)
      
      cell[:arguments] ||= {}
      cell[:arguments][:cell] = cell if cell[:arguments].is_a?(Hash) # TODO: Should we really do this?
      
      trigger_action(cell[:action], cell[:arguments]) if cell[:action]
    end
    
    
    
    # Old aliases, deprecated, will be removed
    alias :createTableViewFromData :create_table_view_from_data
    alias :updateTableViewData :update_table_view_data
    alias :cellAtSectionAndIndex :cell_at_section_and_index    
    
  end
end
