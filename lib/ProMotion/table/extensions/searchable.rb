module ProMotion
  module Table
    module Searchable

      def make_searchable(params={})
        params = set_searchable_param_defaults(params)

        search_bar = create_search_bar(params)

        if params[:search_bar] && params[:search_bar][:placeholder]
          search_bar.placeholder = params[:search_bar][:placeholder]
        end

        @table_search_display_controller = UISearchDisplayController.alloc.initWithSearchBar(search_bar, contentsController: params[:content_controller])
        @table_search_display_controller.delegate = params[:delegate]
        @table_search_display_controller.searchResultsDataSource = params[:data_source]
        @table_search_display_controller.searchResultsDelegate = params[:search_results_delegate]

        self.table_view.tableHeaderView = search_bar
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

      ######### iOS methods, headless camel case #######

      def searchDisplayController(controller, shouldReloadTableForSearchString:search_string)
        @promotion_table_data.search(search_string)
        true
      end

      def searchDisplayControllerWillEndSearch(controller)
        @promotion_table_data.stop_searching
        @promotion_table_data_data = nil
        self.table_view.setScrollEnabled true
        self.table_view.reloadData
        @table_search_display_controller.delegate.will_end_search if @table_search_display_controller.delegate.respond_to? "will_end_search"
      end

      def searchDisplayControllerWillBeginSearch(controller)
        self.table_view.setScrollEnabled false
        @table_search_display_controller.delegate.will_begin_search if @table_search_display_controller.delegate.respond_to? "will_begin_search"
      end
    end
  end
end
