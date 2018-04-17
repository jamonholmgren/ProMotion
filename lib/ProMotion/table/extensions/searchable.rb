module ProMotion
  module Table
    module Searchable

      def search_controller
        @search_controller ||= UISearchController.alloc.initWithSearchResultsController(nil)
      end

      def make_searchable(params = nil) # params argument is deprecated. No longer need to use it.
        params = get_searchable_params

        self.definesPresentationContext = true
        search_controller.delegate = params[:delegate]
        search_controller.searchResultsUpdater = params[:search_results_updater]
        search_controller.hidesNavigationBarDuringPresentation = params[:hides_nav_bar]
        search_controller.dimsBackgroundDuringPresentation = params[:obscures_background] # iOS 8+ (not deprecated yet)
        # search_controller.obscuresBackgroundDuringPresentation = params[:obscures_background] # iOS 9.1+ recommends using this instead of dimsBackgroundDuringPresentation

        search_bar = search_controller.searchBar
        search_bar.delegate = params[:search_bar_delegate]
        search_bar.placeholder = NSLocalizedString(params[:placeholder], nil) if params[:placeholder]
        if params[:scopes]
          @scopes = params[:scopes]
          search_bar.scopeButtonTitles = @scopes
        end

        if navigationItem && navigationItem.respond_to?(:setSearchController)
          # For iOS 11 and later, we place the search bar in the navigation bar.
          navigationItem.searchController = search_controller
          navigationItem.hidesSearchBarWhenScrolling = params[:hides_search_bar_when_scrolling]
        else
          # For iOS 10 and earlier, we place the search bar in the table view's header.
          search_bar.autoresizingMask = UIViewAutoresizingFlexibleWidth
          tableView.tableHeaderView = search_bar
          if params[:hide_initially]
            tableView.contentOffset = CGPointMake(0, search_bar.frame.size.height)
          end
        end

        @search_controller = search_controller
      end

      def get_searchable_params
        params = self.class.get_searchable_params.dup

        # support camelCase params
        params[:search_results_updater] ||= params[:searchResultsUpdater]
        params[:hides_nav_bar] = params[:hidesNavigationBarDuringPresentation] if params[:hides_nav_bar].nil?
        params[:obscures_background] = params[:obscuresBackgroundDuringPresentation] if params[:obscures_background].nil?
        params[:hides_search_bar_when_scrolling] = params[:hidesSearchBarWhenScrolling] if params[:hides_search_bar_when_scrolling].nil?

        params[:delegate] ||= self
        params[:search_results_updater] ||= self
        params[:search_bar_delegate] ||= self
        params[:hides_nav_bar] = true if params[:hides_nav_bar].nil?
        params[:obscures_background] = false if params[:obscures_background].nil?
        params[:hides_search_bar_when_scrolling] = false if params[:hides_search_bar_when_scrolling].nil?

        params
      end

      ######### UISearchControllerDelegate methods #######

      def willPresentSearchController(search_controller)
        search_controller.delegate.will_begin_search if search_controller.delegate.respond_to? "will_begin_search"
      end

      def willDismissSearchController(search_controller)
        search_controller.delegate.will_end_search if search_controller.delegate.respond_to? "will_end_search"
      end

      ######### UISearchResultsUpdating protocol methods #########

      def updateSearchResultsForSearchController(search_controller)
        search_text = search_controller.searchBar.text
        if search_text.empty?
          promotion_table_data.clear_filter
        else
          promotion_table_data.search(search_text)
        end
        table_view.reloadData
      end

      def searchBar(search_bar, selectedScopeButtonIndexDidChange: selected_scope_index)
        try :did_change_selected_scope, selected_scope_index
      end
    end
  end
end
