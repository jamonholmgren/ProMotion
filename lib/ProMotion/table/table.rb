module ProMotion
  module Table
    include ProMotion::Styling
    include ProMotion::Table::Searchable
    include ProMotion::Table::Refreshable
    include ProMotion::Table::Indexable
    include ProMotion::Table::Longpressable
    include ProMotion::Table::Utils
    include ProMotion::TableBuilder

    attr_reader :promotion_table_data

    def table_view
      self.view
    end

    def screen_setup
      check_table_data
      set_up_header_footer_views
      set_up_searchable
      set_up_refreshable
      set_up_longpressable
      set_up_row_height
    end

    def on_live_reload
      update_table_data
    end

    def check_table_data
      mp("Missing #table_data method in TableScreen #{self.class.to_s}.", force_color: :red) unless self.respond_to?(:table_data)
    end

    def promotion_table_data
      @promotion_table_data ||= TableData.new(table_data, table_view, setup_search_method)
    end

    def set_up_header_footer_views
      [:header, :footer].each do |hf_view|
        if self.respond_to?("table_#{hf_view}_view".to_sym)
          view = self.send("table_#{hf_view}_view")
          if view.is_a? UIView
            self.tableView.send(camelize("set_table_#{hf_view}_view:"), view)
          else
            mp "Table #{hf_view} view must be a UIView.", force_color: :yellow
          end
        end
      end
    end

    def set_up_searchable
      if self.class.respond_to?(:get_searchable) && self.class.get_searchable
        self.make_searchable(content_controller: self, search_bar: self.class.get_searchable_params)
        if self.class.get_searchable_params[:hide_initially]
          self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height)
        end
      end
    end

    def setup_search_method
      params = self.class.get_searchable_params
      if params.nil?
        return nil
      else
        @search_method || begin
          params = self.class.get_searchable_params
          @search_action = params[:with] || params[:find_by] || params[:search_by] || params[:filter_by]
          @search_action = method(@search_action) if @search_action.is_a?(Symbol) || @search_action.is_a?(String)
          @search_action
        end
      end
    end

    def set_up_refreshable
      if self.class.respond_to?(:get_refreshable) && self.class.get_refreshable
        if defined?(UIRefreshControl)
          self.make_refreshable(self.class.get_refreshable_params)
        else
          mp "To use the refresh control on < iOS 6, you need to include the CocoaPod 'CKRefreshControl'.", force_color: :yellow
        end
      end
    end

    def set_up_longpressable
      if self.class.respond_to?(:get_longpressable) && self.class.get_longpressable
        self.make_longpressable(self.class.get_longpressable_params)
      end
    end

    def set_up_row_height
      if self.class.respond_to?(:get_row_height) && params = self.class.get_row_height
        self.view.rowHeight = params[:height]
        self.view.estimatedRowHeight = params[:estimated]
      end
    end

    def searching?
      self.promotion_table_data.filtered
    end

    def original_search_string
      self.promotion_table_data.original_search_string
    end

    def search_string
      self.promotion_table_data.search_string
    end

    def update_table_view_data(data, args = {})
      self.promotion_table_data.data = data
      if args[:index_paths]
        args[:animation] ||= UITableViewRowAnimationNone

        table_view.beginUpdates
        table_view.reloadRowsAtIndexPaths(Array(args[:index_paths]), withRowAnimation: args[:animation])
        table_view.endUpdates
      else
        table_view.reloadData
      end

      if searching? && @table_search_display_controller.respond_to?(:searchResultsTableView)
        @table_search_display_controller.searchResultsTableView.reloadData
      end
    end

    def accessory_toggled_switch(switch)
      table_cell = closest_parent(UITableViewCell, switch)
      index_path = closest_parent(UITableView, table_cell).indexPathForCell(table_cell)

      if index_path
        data_cell = cell_at(index_path: index_path)
        data_cell[:accessory][:arguments][:value] = switch.isOn if data_cell[:accessory][:arguments].is_a?(Hash)
        trigger_action(data_cell[:accessory][:action], data_cell[:accessory][:arguments], index_path) if data_cell[:accessory][:action]
      end
    end

    def delete_row(index_paths, animation = nil)
      deletable_index_paths = []
      Array(index_paths).each do |index_path|
        delete_cell = false

        delete_cell = trigger_action(:on_cell_deleted, cell_at(index_path: index_path), index_path) if respond_to?(:on_cell_deleted)
        unless delete_cell == false
          self.promotion_table_data.delete_cell(index_path: index_path)
          deletable_index_paths << index_path
        end
      end
      table_view.deleteRowsAtIndexPaths(deletable_index_paths, withRowAnimation: map_row_animation_symbol(animation)) if deletable_index_paths.length > 0
    end

    def update_table_data(args = {})
      args = { index_paths: args } unless args.is_a?(Hash)

      self.update_table_view_data(self.table_data, args)
      self.promotion_table_data.search(search_string) if searching?
    end

    def toggle_edit_mode(animated = true)
      edit_mode({enabled: !editing?, animated: animated})
    end

    def edit_mode(args = {})
      args[:enabled] = false if args[:enabled].nil?
      args[:animated] = true if args[:animated].nil?

      setEditing(args[:enabled], animated:args[:animated])
    end

    def edit_mode?
      !!isEditing
    end

    # Returns the data cell
    def cell_at(args = {})
      self.promotion_table_data.cell(args)
    end

    ########## Cocoa touch methods #################
    def numberOfSectionsInTableView(_)
      self.promotion_table_data.sections.length
    end

    # Number of cells
    def tableView(_, numberOfRowsInSection: section)
      self.promotion_table_data.section_length(section)
    end

    def tableView(_, titleForHeaderInSection: section)
      section = promotion_table_data.section(section)
      section && section[:title]
    end

    def tableView(_, titleForFooterInSection: section)
      section = promotion_table_data.section(section)
      section && section[:footer]
    end

    # Set table_data_index if you want the right hand index column (jumplist)
    def sectionIndexTitlesForTableView(_)
      return if self.promotion_table_data.filtered
      return self.table_data_index if self.respond_to?(:table_data_index)
      nil
    end

    def tableView(_, cellForRowAtIndexPath: index_path)
      params = index_path_to_section_index(index_path: index_path)
      data_cell = cell_at(index: params[:index], section: params[:section])
      return UITableViewCell.alloc.init unless data_cell
      create_table_cell(data_cell)
    end

    def tableView(_, willDisplayCell: table_cell, forRowAtIndexPath: index_path)
      data_cell = cell_at(index_path: index_path)
      try :will_display_cell, table_cell, index_path
      table_cell.send(:will_display) if table_cell.respond_to?(:will_display)
      table_cell.send(:restyle!) if table_cell.respond_to?(:restyle!) # Teacup compatibility
    end

    def tableView(_, heightForRowAtIndexPath: index_path)
      (cell_at(index_path: index_path)[:height] || tableView.rowHeight).to_f
    end

    def tableView(table_view, didSelectRowAtIndexPath: index_path)
      data_cell = cell_at(index_path: index_path)
      table_view.deselectRowAtIndexPath(index_path, animated: true) unless data_cell[:keep_selection] == true
      trigger_action(data_cell[:action], data_cell[:arguments], index_path) if data_cell[:action]
    end

    def tableView(_, canEditRowAtIndexPath:index_path)
      data_cell = cell_at(index_path: index_path, unfiltered: !searching?)
      [:insert,:delete].include?(data_cell[:editing_style])
    end

    def tableView(_, editingStyleForRowAtIndexPath: index_path)
      data_cell = cell_at(index_path: index_path, unfiltered: !searching?)
      map_cell_editing_style(data_cell[:editing_style])
    end

    def tableView(_, commitEditingStyle: editing_style, forRowAtIndexPath: index_path)
      if editing_style == UITableViewCellEditingStyleDelete
        delete_row(index_path)
      end
    end

    def tableView(_, canMoveRowAtIndexPath:index_path)
      data_cell = cell_at(index_path: index_path, unfiltered: !searching?)

      if (!data_cell[:moveable].nil? || data_cell[:moveable].is_a?(Symbol)) && data_cell[:moveable] != false
        true
      else
        false
      end
    end

    def tableView(_, targetIndexPathForMoveFromRowAtIndexPath:source_index_path, toProposedIndexPath:proposed_destination_index_path)
      data_cell = cell_at(index_path: source_index_path, unfiltered: !searching?)

      if data_cell[:moveable] == :section && source_index_path.section != proposed_destination_index_path.section
        source_index_path
      else
        proposed_destination_index_path
      end
    end

    def tableView(_, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
      self.promotion_table_data.move_cell(from_index_path, to_index_path)

      if self.respond_to?("on_cell_moved:")
        args = {
          paths: {
            from: from_index_path,
            to: to_index_path
          },
          cell: self.promotion_table_data.section(to_index_path.section)[:cells][to_index_path.row]
        }
        send(:on_cell_moved, args)
      else
        mp "Implement the on_cell_moved method in your PM::TableScreen to be notified when a user moves a cell.", force_color: :yellow
      end
    end

    def tableView(table_view, sectionForSectionIndexTitle: title, atIndex: index)
      return index unless ["{search}", UITableViewIndexSearch].include?(self.table_data_index[0])

      if index == 0
        table_view.scrollRectToVisible(CGRectMake(0.0, 0.0, 1.0, 1.0), animated: false)
        NSNotFound
      else
        index - 1
      end
    end

    def deleteRowsAtIndexPaths(index_paths, withRowAnimation: animation)
      mp "ProMotion expects you to use 'delete_cell(index_paths, animation)'' instead of 'deleteRowsAtIndexPaths(index_paths, withRowAnimation:animation)'.", force_color: :yellow
      delete_row(index_paths, animation)
    end

    # Section header view methods
    def tableView(_, viewForHeaderInSection: index)
      section = promotion_table_data.section(index)
      view = section[:title_view]
      view = section[:title_view].new if section[:title_view].respond_to?(:new)
      view.on_load if view.respond_to?(:on_load)
      view.title = section[:title] if view.respond_to?(:title=)
      view
    end

    def tableView(_, heightForHeaderInSection: index)
      section = promotion_table_data.section(index)
      if section[:title_view] || section[:title].to_s.length > 0
        if section[:title_view_height]
          section[:title_view_height]
        elsif (section_header = tableView(_, viewForHeaderInSection: index)) && section_header.respond_to?(:height)
          section_header.height
        else
          tableView.sectionHeaderHeight
        end
      else
        0.0
      end
    end

    def tableView(_, willDisplayHeaderView:view, forSection:section)
      action = :will_display_header
      if respond_to?(action)
        case self.method(action).arity
        when 0 then self.send(action)
        when 2 then self.send(action, view, section)
        else self.send(action, view)
        end
      end
    end

    # Section footer view methods
    def tableView(_, viewForFooterInSection: index)
      section = promotion_table_data.section(index)
      view = section[:footer_view]
      view = section[:footer_view].new if section[:footer_view].respond_to?(:new)
      view.on_load if view.respond_to?(:on_load)
      view.title = section[:footer] if view.respond_to?(:title=)
      view
    end

    def tableView(_, heightForFooterInSection: index)
      section = promotion_table_data.section(index)
      if section[:footer_view] || section[:footer].to_s.length > 0
        if section[:footer_view_height]
          section[:footer_view_height]
        elsif (section_footer = tableView(_, viewForFooterInSection: index)) && section_footer.respond_to?(:height)
          section_footer.height
        else
          tableView.sectionFooterHeight
        end
      else
        0.0
      end
    end

    def tableView(_, willDisplayFooterView:view, forSection:section)
      action = :will_display_footer
      if respond_to?(action)
        case self.method(action).arity
        when 0 then self.send(action)
        when 2 then self.send(action, view, section)
        else self.send(action, view)
        end
      end
    end

    protected

    def map_cell_editing_style(symbol)
      {
        none:   UITableViewCellEditingStyleNone,
        delete: UITableViewCellEditingStyleDelete,
        insert: UITableViewCellEditingStyleInsert
      }[symbol] || symbol || UITableViewCellEditingStyleNone
    end

    def map_row_animation_symbol(symbol)
      symbol ||= UITableViewRowAnimationAutomatic
      {
        fade:       UITableViewRowAnimationFade,
        right:      UITableViewRowAnimationRight,
        left:       UITableViewRowAnimationLeft,
        top:        UITableViewRowAnimationTop,
        bottom:     UITableViewRowAnimationBottom,
        none:       UITableViewRowAnimationNone,
        middle:     UITableViewRowAnimationMiddle,
        automatic:  UITableViewRowAnimationAutomatic
      }[symbol] || symbol || UITableViewRowAnimationAutomatic
    end

    def self.included(base)
      base.extend(TableClassMethods)
    end
  end
end
