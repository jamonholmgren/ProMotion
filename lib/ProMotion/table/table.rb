module ProMotion
  module Table
    include ProMotion::Styling
    include ProMotion::Table::Searchable
    include ProMotion::Table::Refreshable
    include ProMotion::Table::Indexable
    include ProMotion::Table::Longpressable
    include ProMotion::Table::Utils

    attr_reader :promotion_table_data

    def table_view
      self.view
    end

    def screen_setup
      check_table_data
      set_up_searchable
      set_up_refreshable
      set_up_longpressable
    end

    def check_table_data
      PM.logger.error "Missing #table_data method in TableScreen #{self.class.to_s}." unless self.respond_to?(:table_data)
    end

    def promotion_table_data
      @promotion_table_data ||= TableData.new(table_data, table_view)
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

    def set_up_longpressable
      if self.class.respond_to?(:get_longpressable) && self.class.get_longpressable
        self.make_longpressable(self.class.get_longpressable_params)
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
      @table_search_display_controller.searchResultsTableView.reloadData if searching?
    end

    def trigger_action(action, arguments, index_path)
      return PM.logger.info "Action not implemented: #{action.to_s}" unless self.respond_to?(action)

      case self.method(action).arity
      when 0 then self.send(action) # Just call the method
      when 2 then self.send(action, arguments, index_path) # Send arguments and index path
      else self.send(action, arguments) # Send arguments
      end
    end

    def accessory_toggled_switch(switch)
      table_cell = closest_parent(UITableViewCell, switch)
      index_path = closest_parent(UITableView, table_cell).indexPathForCell(table_cell)

      if index_path
        data_cell = promotion_table_data.cell(section: index_path.section, index: index_path.row)
        data_cell[:accessory][:arguments][:value] = switch.isOn if data_cell[:accessory][:arguments].is_a?(Hash)
        trigger_action(data_cell[:accessory][:action], data_cell[:accessory][:arguments], index_path) if data_cell[:accessory][:action]
      end
    end

    def delete_row(index_paths, animation = nil)
      deletable_index_paths = []
      index_paths = [index_paths] if index_paths.kind_of?(NSIndexPath)
      index_paths.each do |index_path|
        delete_cell = false
        delete_cell = send(:on_cell_deleted, self.promotion_table_data.cell(index_path: index_path)) if self.respond_to?("on_cell_deleted:")
        unless delete_cell == false
          self.promotion_table_data.delete_cell(index_path: index_path)
          deletable_index_paths << index_path
        end
      end
      table_view.deleteRowsAtIndexPaths(deletable_index_paths, withRowAnimation: map_row_animation_symbol(animation)) if deletable_index_paths.length > 0
    end

    def table_view_cell(params={})
      params = index_path_to_section_index(params)
      data_cell = self.promotion_table_data.cell(section: params[:section], index: params[:index])
      return UITableViewCell.alloc.init unless data_cell
      create_table_cell(data_cell)
    end

    def create_table_cell(data_cell)
      new_cell = nil
      table_cell = table_view.dequeueReusableCellWithIdentifier(data_cell[:cell_identifier]) || begin
        new_cell = data_cell[:cell_class].alloc.initWithStyle(data_cell[:cell_style], reuseIdentifier:data_cell[:cell_identifier])
        new_cell.extend(PM::TableViewCellModule) unless new_cell.is_a?(PM::TableViewCellModule)
        new_cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
        new_cell.clipsToBounds = true # fix for changed default in 7.1
        new_cell
      end
      table_cell.setup(data_cell, self)
      table_cell.send(:on_reuse) if !new_cell && table_cell.respond_to?(:on_reuse)
      table_cell
    end

    def update_table_data(args = {})
      # Try and detect if the args param is a NSIndexPath or an array of them
      args = { index_paths: args } if args.is_a?(NSIndexPath) || (args.is_a?(Array) && array_all_members_of?(args, NSIndexPath))

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

    ########## Cocoa touch methods #################
    def numberOfSectionsInTableView(table_view)
      self.promotion_table_data.sections.length
    end

    # Number of cells
    def tableView(table_view, numberOfRowsInSection: section)
      self.promotion_table_data.section_length(section)
    end

    def tableView(table_view, titleForHeaderInSection: section)
      section = promotion_table_data.section(section)
      section && section[:title]
    end

    # Set table_data_index if you want the right hand index column (jumplist)
    def sectionIndexTitlesForTableView(table_view)
      return if self.promotion_table_data.filtered
      return self.table_data_index if self.respond_to?(:table_data_index)
      nil
    end

    def tableView(table_view, cellForRowAtIndexPath: index_path)
      table_view_cell(index_path: index_path)
    end

    def tableView(table_view, willDisplayCell: table_cell, forRowAtIndexPath: index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path)
      set_attributes table_cell, data_cell[:properties] if data_cell[:properties]
      table_cell.send(:will_display) if table_cell.respond_to?(:will_display)
      table_cell.send(:restyle!) if table_cell.respond_to?(:restyle!) # Teacup compatibility
    end

    def tableView(table_view, heightForRowAtIndexPath: index_path)
      (self.promotion_table_data.cell(index_path: index_path)[:height] || table_view.rowHeight).to_f
    end

    def tableView(table_view, didSelectRowAtIndexPath: index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path)
      table_view.deselectRowAtIndexPath(index_path, animated: true) unless data_cell[:keep_selection] == true
      trigger_action(data_cell[:action], data_cell[:arguments], index_path) if data_cell[:action]
    end

    def tableView(table_view, editingStyleForRowAtIndexPath: index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path, unfiltered: true)
      map_cell_editing_style(data_cell[:editing_style])
    end

    def tableView(table_view, commitEditingStyle: editing_style, forRowAtIndexPath: index_path)
      if editing_style == UITableViewCellEditingStyleDelete
        delete_row(index_path)
      end
    end

    def tableView(tableView, canMoveRowAtIndexPath:index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path, unfiltered: true)

      if (!data_cell[:moveable].nil? || data_cell[:moveable].is_a?(Symbol)) && data_cell[:moveable] != false
        true
      else
        false
      end
    end

    def tableView(tableView, targetIndexPathForMoveFromRowAtIndexPath:source_index_path, toProposedIndexPath:proposed_destination_index_path)
      data_cell = self.promotion_table_data.cell(index_path: source_index_path, unfiltered: true)

      if data_cell[:moveable] == :section && source_index_path.section != proposed_destination_index_path.section
        source_index_path
      else
        proposed_destination_index_path
      end
    end

    def tableView(tableView, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
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
        PM.logger.warn "Implement the on_cell_moved method in your PM::TableScreen to be notified when a user moves a cell."
      end
    end

    def tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
      return index unless ["{search}", UITableViewIndexSearch].include?(self.table_data_index[0])

      if index == 0
        tableView.scrollRectToVisible(CGRectMake(0.0, 0.0, 1.0, 1.0), animated: false)
        NSNotFound
      else
        index - 1
      end
    end

    def deleteRowsAtIndexPaths(index_paths, withRowAnimation: animation)
      PM.logger.warn "ProMotion expects you to use 'delete_cell(index_paths, animation)'' instead of 'deleteRowsAtIndexPaths(index_paths, withRowAnimation:animation)'."
      delete_row(index_paths, animation)
    end

    # Section view methods
    def tableView(table_view, viewForHeaderInSection: index)
      section = promotion_table_data.section(index)
      view = nil
      view = section[:title_view].new if section[:title_view].respond_to?(:new)
      view.title = section[:title] if view.respond_to?(:title=)
      view
    end

    def tableView(table_view, heightForHeaderInSection: index)
      section = promotion_table_data.section(index)
      if section[:title_view] || section[:title].to_s.length > 0
        section[:title_view_height] || tableView.sectionHeaderHeight
      else
        0.0
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

    module TableClassMethods
      def table_style
        UITableViewStylePlain
      end

      # Searchable
      def searchable(params={})
        @searchable_params = params
        @searchable = true
      end

      def get_searchable_params
        @searchable_params ||= nil
      end

      def get_searchable
        @searchable ||= false
      end

      # Refreshable
      def refreshable(params = {})
        @refreshable_params = params
        @refreshable = true
      end

      def get_refreshable
        @refreshable ||= false
      end

      def get_refreshable_params
        @refreshable_params ||= nil
      end

      # Indexable
      def indexable(params = {})
        @indexable_params = params
        @indexable = true
      end

      def get_indexable
        @indexable ||= false
      end

      def get_indexable_params
        @indexable_params ||= nil
      end

      # Longpressable
      def longpressable(params = {})
        @longpressable_params = params
        @longpressable = true
      end

      def get_longpressable
        @longpressable ||= false
      end

      def get_longpressable_params
        @longpressable_params ||= nil
      end
    end

    def self.included(base)
      base.extend(TableClassMethods)
    end

  end
end
