module ProMotion
  module Table
    module Searchable

      def search_controller
        @search_controller ||= UISearchController.alloc.initWithSearchResultsController(nil)
      end

      def make_searchable(params = {})
        params = set_searchable_param_defaults(params)

        self.definesPresentationContext = true
        search_controller.delegate = params[:delegate]
        search_controller.searchResultsUpdater = params[:search_results_updater]
        search_controller.hidesNavigationBarDuringPresentation = params[:hidesNavigationBarDuringPresentation]
        search_controller.dimsBackgroundDuringPresentation = params[:obscuresBackgroundDuringPresentation] # iOS 8+ (not deprecated yet)
        # search_controller.obscuresBackgroundDuringPresentation = params[:obscuresBackgroundDuringPresentation] # iOS 9.1+ recommends using this instead of dimsBackgroundDuringPresentation

        search_bar = search_controller.searchBar
        search_bar.delegate = params[:search_bar_delegate]
        search_bar.autoresizingMask = UIViewAutoresizingFlexibleWidth
        search_bar.placeholder = NSLocalizedString(params[:placeholder], nil) if params[:placeholder]
        if params[:scopes]
          @scopes = params[:scopes]
          search_bar.scopeButtonTitles = @scopes
        end
        tableView.tableHeaderView = search_bar
        search_bar.sizeToFit

        if params[:hide_initially]
          tableView.contentOffset = CGPointMake(0, search_bar.frame.size.height)
        end
      end

      def set_searchable_param_defaults(params)
        # support camelCase params
        params[:search_results_updater] ||= params[:searchResultsUpdater]

        params[:delegate] ||= self
        params[:search_results_updater] ||= self
        params[:search_bar_delegate] ||= self

        if params[:hidesNavigationBarDuringPresentation].nil?
          params[:hidesNavigationBarDuringPresentation] = true
        end

        if params[:obscuresBackgroundDuringPresentation].nil?
          params[:obscuresBackgroundDuringPresentation] = false
        end

        params
      end

      ######### UISearchControllerDelegate methods #######

      def willPresentSearchController(search_controller)
        promotion_table_data.start_searching
        search_controller.delegate.will_begin_search if search_controller.delegate.respond_to? "will_begin_search"
      end

      def willDismissSearchController(search_controller)
        promotion_table_data.stop_searching
        table_view.reloadData
        search_controller.delegate.will_end_search if search_controller.delegate.respond_to? "will_end_search"
      end

      # UISearchResultsUpdating protocol method
      def updateSearchResultsForSearchController(search_controller)
        search_string = search_controller.searchBar.text
        promotion_table_data.search(search_string) if searching?
        update_table_data
      end

      def searchBar(search_bar, selectedScopeButtonIndexDidChange: selected_scope_index)
        try :did_change_selected_scope, selected_scope_index
      end
    end
  end
end
