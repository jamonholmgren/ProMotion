module ProMotion::MotionTable
  module SearchableTable
    def make_searchable(params={})
      params[:content_controller] ||= params[:contentController]
      params[:data_source] ||= params[:searchResultsDataSource]
      params[:search_results_delegate] ||= params[:searchResultsDelegate]

      params[:frame] ||= CGRectMake(0, 0, 320, 44) # TODO: Don't hardcode this...
      params[:content_controller] ||= self
      params[:delegate] ||= self
      params[:data_source] ||= self
      params[:search_results_delegate] ||= self

      search_bar = UISearchBar.alloc.initWithFrame(params[:frame])
      search_bar.autoresizingMask = UIViewAutoresizingFlexibleWidth

      if params[:search_bar] && params[:search_bar][:placeholder]
        search_bar.placeholder = params[:search_bar][:placeholder]
      end

      @contacts_search_display_controller = UISearchDisplayController.alloc.initWithSearchBar(search_bar, contentsController: params[:content_controller])
      @contacts_search_display_controller.delegate = params[:delegate]
      @contacts_search_display_controller.searchResultsDataSource = params[:data_source]
      @contacts_search_display_controller.searchResultsDelegate = params[:search_results_delegate]

      self.table_view.tableHeaderView = search_bar
    end
    alias :makeSearchable :make_searchable

    ######### iOS methods, headless camel case #######

    def searchDisplayController(controller, shouldReloadTableForSearchString:search_string)
      @mt_filtered_data = nil
      @mt_filtered_data = []

      @mt_table_view_groups.each do |section|
        new_section = {}
        new_section[:cells] = []

        section[:cells].each do |cell|
          if cell[:title].to_s.downcase.strip.include?(search_string.downcase.strip)
            new_section[:cells] << cell
          end
        end

        if new_section[:cells] && new_section[:cells].length > 0
          new_section[:title] = section[:title]
          @mt_filtered_data << new_section
        end
      end
      true
    end

    def searchDisplayControllerWillEndSearch(controller)
      @mt_filtered = false
      @mt_filtered_data = nil
      self.table_view.setScrollEnabled true
    end

    def searchDisplayControllerWillBeginSearch(controller)
      @mt_filtered = true
      @mt_filtered_data = []
      self.table_view.setScrollEnabled false
    end
  end
end