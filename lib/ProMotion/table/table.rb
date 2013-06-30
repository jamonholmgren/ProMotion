module ProMotion
  module Table
    include ProMotion::ViewHelper

    def screen_setup
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

    def searching?
      @promotion_table_data.filtered
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
      table_cell = closest_parent(UITableViewCell, switch)
      index_path = closest_parent(UITableView, table_cell).indexPathForCell(table_cell)

      if index_path
        data_cell = cell_at_section_and_index(index_path.section, index_path.row)
        data_cell[:accessory][:arguments] ||= {}
        data_cell[:accessory][:arguments][:value] = switch.isOn if data_cell[:accessory][:arguments].is_a?(Hash)

        trigger_action(data_cell[:accessory][:action], data_cell[:accessory][:arguments]) if data_cell[:accessory][:action]
      end
    end

    def delete_row(index_paths, animation = nil)
      animation ||= UITableViewRowAnimationAutomatic
      index_paths = Array(index_paths)

      index_paths.each do |index_path|
        @promotion_table_data.delete_cell(index_path: index_path)
      end
      table_view.deleteRowsAtIndexPaths(index_paths, withRowAnimation:animation)
    end

    def table_view_cell(params={})
      if params[:index_path]
        params[:section] = params[:index_path].section
        params[:index] = params[:index_path].row
      end

      data_cell = @promotion_table_data.cell(section: params[:section], index: params[:index])
      return UITableViewCell.alloc.init unless data_cell # No data?

      table_cell = create_table_cell(data_cell)

      table_cell
    end

    def create_table_cell(data_cell)
      table_cell = table_view.dequeueReusableCellWithIdentifier(data_cell[:cell_identifier])

      unless table_cell
        data_cell[:cell_style] ||= UITableViewCellStyleSubtitle
        table_cell = data_cell[:cell_class].alloc.initWithStyle(data_cell[:cell_style], reuseIdentifier:data_cell[:cell_identifier])
        table_cell.extend PM::TableViewCellModule unless table_cell.is_a?(PM::TableViewCellModule)
        table_cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
      end

      table_cell.setup(data_cell, self)

      table_cell
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
      if @promotion_table_data.filtered
        nil
      else
        self.table_data_index if self.respond_to?(:table_data_index)
      end
    end

    def tableView(table_view, cellForRowAtIndexPath:index_path)
      table_view_cell(index_path: index_path)
    end

    def tableView(table_view, willDisplayCell: table_cell, forRowAtIndexPath: index_path)
      data_cell = @promotion_table_data.cell(index_path: index_path)
      table_cell.backgroundColor = data_cell[:background_color] if data_cell[:background_color]
      table_cell.send(:restyle!) if table_cell.respond_to?(:restyle!)
    end

    def tableView(table_view, heightForRowAtIndexPath:index_path)
      (@promotion_table_data.cell(index_path: index_path)[:height] || table_view.rowHeight).to_f
    end

    def tableView(table_view, didSelectRowAtIndexPath:index_path)
      data_cell = @promotion_table_data.cell(index_path: index_path)
      table_view.deselectRowAtIndexPath(index_path, animated: true)

      data_cell[:arguments] ||= {}
      data_cell[:arguments][:cell] = data_cell if data_cell[:arguments].is_a?(Hash) # TODO: Should we really do this?

      trigger_action(data_cell[:action], data_cell[:arguments]) if data_cell[:action]
    end

    def tableView(table_view, editingStyleForRowAtIndexPath: index_path)
      data_cell = @promotion_table_data.cell(index_path: index_path)

      case data_cell[:editing_style]
      when nil
        UITableViewCellEditingStyleNone
      when :none
        UITableViewCellEditingStyleNone
      when :delete
        UITableViewCellEditingStyleDelete
      when :insert
        UITableViewCellEditingStyleInsert
      else
        data_cell[:editing_style]
      end
    end

    def tableView(table_view, commitEditingStyle: editing_style, forRowAtIndexPath: index_path)
      if editing_style == UITableViewCellEditingStyleDelete
        delete_cell(index_path)
      end
    end

    def tableView(tableView, sectionForSectionIndexTitle:title, atIndex:index)
      return index unless ["{search}", UITableViewIndexSearch].include?(self.table_data_index[0])

      if index == 0
        tableView.setContentOffset(CGPointZero, animated:false)
        NSNotFound
      else
        index - 1
      end
    end

    def deleteRowsAtIndexPaths(index_paths, withRowAnimation:animation)
      PM.logger.warn "ProMotion expects you to use 'delete_cell(index_paths, animation)'' instead of 'deleteRowsAtIndexPaths(index_paths, withRowAnimation:animation)'."
      delete_cell(index_paths, animation)
    end

  end
end
