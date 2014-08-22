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

    def update_table_view_data(data)
      self.promotion_table_data.data = data
      table_view.reloadData
      @table_search_display_controller.searchResultsTableView.reloadData if searching?
    end

    def trigger_action(action, arguments)
      return PM.logger.info "Action not implemented: #{action.to_s}" unless self.respond_to?(action)
      return self.send(action) if self.method(action).arity == 0
      self.send(action, arguments)
    end

    def accessory_toggled_switch(switch)
      table_cell = closest_parent(UITableViewCell, switch)
      index_path = closest_parent(UITableView, table_cell).indexPathForCell(table_cell)

      if index_path
        data_cell = promotion_table_data.cell(section: index_path.section, index: index_path.row)
        data_cell[:accessory][:arguments] ||= {}
        data_cell[:accessory][:arguments][:value] = switch.isOn if data_cell[:accessory][:arguments].is_a?(Hash)
        trigger_action(data_cell[:accessory][:action], data_cell[:accessory][:arguments]) if data_cell[:accessory][:action]
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
      table_view.deleteRowsAtIndexPaths(deletable_index_paths, withRowAnimation:map_row_animation_symbol(animation)) if deletable_index_paths.length > 0
    end

    def table_view_cell(params={})
      params = index_path_to_section_index(params)
      data_cell = self.promotion_table_data.cell(section: params[:section], index: params[:index])
      return UITableViewCell.alloc.init unless data_cell
      create_table_cell(data_cell)
    end

    def create_table_cell(data_cell)
      table_cell = table_view.dequeueReusableCellWithIdentifier(data_cell[:cell_identifier]) || begin
        table_cell = data_cell[:cell_class].alloc.initWithStyle(data_cell[:cell_style], reuseIdentifier:data_cell[:cell_identifier])
        table_cell.extend(PM::TableViewCellModule) unless table_cell.is_a?(PM::TableViewCellModule)
        table_cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
        table_cell.clipsToBounds = true # fix for changed default in 7.1
        table_cell
      end
      table_cell.setup(data_cell, self)
      table_cell
    end

    def update_table_data
      self.update_table_view_data(self.table_data)
      self.promotion_table_data.search(search_string) if searching?
    end

    ########## Cocoa touch methods #################
    def numberOfSectionsInTableView(table_view)
      self.promotion_table_data.sections.length
    end

    # Number of cells
    def tableView(table_view, numberOfRowsInSection:section)
      self.promotion_table_data.section_length(section)
    end

    def tableView(table_view, titleForHeaderInSection:section)
      section = promotion_table_data.section(section)
      section && section[:title]
    end

    # Set table_data_index if you want the right hand index column (jumplist)
    def sectionIndexTitlesForTableView(table_view)
      return if self.promotion_table_data.filtered
      return self.table_data_index if self.respond_to?(:table_data_index)
      nil
    end

    def tableView(table_view, cellForRowAtIndexPath:index_path)
      table_view_cell(index_path: index_path)
    end

    def tableView(table_view, willDisplayCell: table_cell, forRowAtIndexPath: index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path)
      set_attributes table_cell, data_cell[:style] if data_cell[:style]
      table_cell.send(:will_display) if table_cell.respond_to?(:will_display)
      table_cell.send(:restyle!) if table_cell.respond_to?(:restyle!) # Teacup compatibility
    end

    def tableView(table_view, heightForRowAtIndexPath:index_path)
      (self.promotion_table_data.cell(index_path: index_path)[:height] || table_view.rowHeight).to_f
    end

    def tableView(table_view, didSelectRowAtIndexPath:index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path)
      table_view.deselectRowAtIndexPath(index_path, animated: true) unless data_cell[:keep_selection] == true
      trigger_action(data_cell[:action], data_cell[:arguments]) if data_cell[:action]
    end

    def tableView(table_view, editingStyleForRowAtIndexPath: index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path)
      map_cell_editing_style(data_cell[:editing_style])
    end

    def tableView(table_view, commitEditingStyle: editing_style, forRowAtIndexPath: index_path)
      if editing_style == UITableViewCellEditingStyleDelete
        delete_row(index_path)
      end
    end

    def tableView(tableView, sectionForSectionIndexTitle:title, atIndex:index)
      return index unless ["{search}", UITableViewIndexSearch].include?(self.table_data_index[0])

      if index == 0
        tableView.scrollRectToVisible(CGRectMake(0.0, 0.0, 1.0, 1.0), animated:false)
        NSNotFound
      else
        index - 1
      end
    end

    def deleteRowsAtIndexPaths(index_paths, withRowAnimation:animation)
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
