module ProMotion::MotionTable
  module SearchableTable
    def makeSearchable(params={})
      params[:frame] ||= CGRectMake(0, 0, 320, 44)
      params[:contentController] ||= self
      params[:delegate] ||= self
      params[:searchResultsDataSource] ||= self
      params[:searchResultsDelegate] ||= self

      searchBar = UISearchBar.alloc.initWithFrame(params[:frame])
      if params[:searchBar] && params[:searchBar][:placeholder]
        searchBar.placeholder = params[:searchBar][:placeholder]
      end

      @contactsSearchDisplayController = UISearchDisplayController.alloc.initWithSearchBar(searchBar, contentsController: params[:contentController])
      @contactsSearchDisplayController.delegate = params[:delegate]
      @contactsSearchDisplayController.searchResultsDataSource = params[:searchResultsDataSource]
      @contactsSearchDisplayController.searchResultsDelegate = params[:searchResultsDelegate]
      
      self.tableView.tableHeaderView = searchBar
    end

    def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
      @mt_filtered_data = nil
      @mt_filtered_data = []

      @mt_table_view_groups.each do |section|
        newSection = {}
        newSection[:cells] = []

        section[:cells].each do |cell|
          if cell[:title].to_s.downcase.strip.include?(searchString.downcase.strip)
            newSection[:cells] << cell
          end
        end

        if newSection[:cells] && newSection[:cells].length > 0
          newSection[:title] = section[:title]
          @mt_filtered_data << newSection
        end
      end

      true
    end

    def searchDisplayControllerWillEndSearch(controller)
      @mt_filtered = false
      @mt_filtered_data = nil
      self.tableView.setScrollEnabled true
    end

    def searchDisplayControllerWillBeginSearch(controller)
      @mt_filtered = true
      @mt_filtered_data = []
      self.tableView.setScrollEnabled false
    end
  end
end