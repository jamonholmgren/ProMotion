module ProMotion
  module Table

    include ProMotion::Styling
    include ProMotion::Table::Searchable
    include ProMotion::Table::Refreshable
    include ProMotion::Table::Indexable

    def table_view
      @table_view ||= begin
        t = UITableView.alloc.initWithFrame(self.view.frame, style: table_style)
        t.dataSource = self
        t.delegate = self
        t
      end
    end

    def table_style
      UITableViewStylePlain
    end

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
      # before access self.table_data, create UITableView and call on_load
      table_view

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

    def original_search_string
      @promotion_table_data.original_search_string
    end

    def search_string
      @promotion_table_data.search_string
    end

    def update_table_view_data(data)
      create_table_view_from_data(data) unless @promotion_table_data
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
      animation = map_row_animation_symbol(animation)
      index_paths = [index_paths] if index_paths.kind_of?(NSIndexPath)
      deletable_index_paths = []

      index_paths.each do |index_path|
        delete_cell = false
        delete_cell = send(:on_cell_deleted, @promotion_table_data.cell(index_path: index_path)) if self.respond_to?("on_cell_deleted:")
        unless delete_cell == false
          @promotion_table_data.delete_cell(index_path: index_path)
          deletable_index_paths << index_path
        end
      end
      table_view.deleteRowsAtIndexPaths(deletable_index_paths, withRowAnimation:animation) if deletable_index_paths.length > 0
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

    def update_table_data
      self.update_table_view_data(self.table_data)
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
      return nil if @promotion_table_data.filtered

      if self.respond_to?(:table_data_index)
        self.table_data_index
      else
        nil
      end
    end

    def tableView(table_view, cellForRowAtIndexPath:index_path)
      table_view_cell(index_path: index_path)
    end

    def tableView(table_view, willDisplayCell: table_cell, forRowAtIndexPath: index_path)
      data_cell = @promotion_table_data.cell(index_path: index_path)
      table_cell.backgroundColor = data_cell[:background_color] || UIColor.whiteColor
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
      when nil, :none
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
        delete_row(index_path)
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
      delete_row(index_paths, animation)
    end

    # Section view methods
    def tableView(table_view, viewForHeaderInSection: index)
      section = section_at_index(index)

      if section[:title_view]
        klass      = section[:title_view]
        view       = klass.new if klass.respond_to?(:new)
        view.title = section[:title] if view.respond_to?(:title=)
        view
      else
        nil
      end
    end

    def tableView(table_view, heightForHeaderInSection: index)
      section = section_at_index(index)

      if section[:title_view] || (section[:title] && !section[:title].empty?)
        section[:title_view_height] || tableView.sectionHeaderHeight
      else
        0.0
      end
    end

    protected

    def map_row_animation_symbol(symbol)
      symbol ||= UITableViewRowAnimationAutomatic
      {
        automatic:  UITableViewRowAnimationAutomatic,
        fade:       UITableViewRowAnimationFade,
        right:      UITableViewRowAnimationRight,
        left:       UITableViewRowAnimationLeft,
        top:        UITableViewRowAnimationTop,
        bottom:     UITableViewRowAnimationBottom,
        none:       UITableViewRowAnimationNone,
        middle:     UITableViewRowAnimationMiddle,
        automatic:  UITableViewRowAnimationAutomatic
      }[symbol] || symbol
    end

    module TableClassMethods
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

    end

    def self.included(base)
      base.extend(TableClassMethods)
    end

  end
end
