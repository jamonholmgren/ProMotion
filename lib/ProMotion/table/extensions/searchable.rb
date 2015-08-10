module ProMotion
  module Table
    module Searchable

      def make_searchable(params={})
        params = set_searchable_param_defaults(params)

        search_bar = create_search_bar(params)

        if params[:search_bar] && params[:search_bar][:placeholder]
          search_bar.placeholder = params[:search_bar][:placeholder]
        end

        @no_results_text = params[:search_bar][:no_results] if params[:search_bar][:no_results]

        @table_search_display_controller = UISearchDisplayController.alloc.initWithSearchBar(search_bar, contentsController: params[:content_controller])
        @table_search_display_controller.delegate = params[:delegate]
        @table_search_display_controller.searchResultsDataSource = params[:data_source]
        @table_search_display_controller.searchResultsDelegate = params[:search_results_delegate]

        self.tableView.tableHeaderView = search_bar
      end
      alias :makeSearchable :make_searchable

      def set_searchable_param_defaults(params)
        params[:content_controller] ||= params[:contentController]
        params[:data_source] ||= params[:searchResultsDataSource]
        params[:search_results_delegate] ||= params[:searchResultsDelegate]

        params[:frame] ||= CGRectMake(0, 0, 320, 44) # TODO: Don't hardcode this...
        params[:content_controller] ||= self
        params[:delegate] ||= self
        params[:data_source] ||= self
        params[:search_results_delegate] ||= self
        params
      end

      def create_search_bar(params)
        search_bar = UISearchBar.alloc.initWithFrame(params[:frame])
        search_bar.autoresizingMask = UIViewAutoresizingFlexibleWidth
        search_bar
      end

      def set_no_results_text(controller)
        Dispatch::Queue.main.async do
          controller.searchResultsTableView.subviews.each do |v|
            v.text = @no_results_text if v.is_a?(UILabel)
          end
        end if @no_results_text
      end

      ######### iOS methods, headless camel case #######

      def searchDisplayController(controller, shouldReloadTableForSearchString:search_string)
        self.promotion_table_data.search(search_string)
        set_no_results_text(controller) if @no_results_text
        true
      end

      def searchDisplayControllerWillEndSearch(controller)
        self.promotion_table_data.stop_searching
        self.table_view.setScrollEnabled true
        self.table_view.reloadData
        @table_search_display_controller.delegate.will_end_search if @table_search_display_controller.delegate.respond_to? "will_end_search"
      end

      def searchDisplayControllerWillBeginSearch(controller)
        self.table_view.setScrollEnabled false
        @table_search_display_controller.delegate.will_begin_search if @table_search_display_controller.delegate.respond_to? "will_begin_search"
      end

      def searchDisplayController(controller, didLoadSearchResultsTableView: tableView)
        tableView.rowHeight = self.table_view.rowHeight
      end
    end
  end
end
