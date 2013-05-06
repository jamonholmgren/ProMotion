module ProMotion::MotionTable
  module RefreshableTable
    def make_refreshable
      @refresh = UIRefreshControl.alloc.init
      @refresh.attributedTitle = NSAttributedString.alloc.initWithString("Pull to Refresh")
      @refresh.addTarget(self, action:'refreshView:', forControlEvents:UIControlEventValueChanged)
      self.refreshControl = @refresh
      # @on_refresh = get_refreshable_block


      # params[:content_controller] ||= params[:contentController]
      # params[:data_source] ||= params[:searchResultsDataSource]
      # params[:search_results_delegate] ||= params[:searchResultsDelegate]

      # params[:frame] ||= CGRectMake(0, 0, 320, 44) # TODO: Don't hardcode this...
      # params[:content_controller] ||= self
      # params[:delegate] ||= self
      # params[:data_source] ||= self
      # params[:search_results_delegate] ||= self

      # search_bar = UISearchBar.alloc.initWithFrame(params[:frame])
      # search_bar.autoresizingMask = UIViewAutoresizingFlexibleWidth

      # if params[:search_bar] && params[:search_bar][:placeholder]
      #   search_bar.placeholder = params[:search_bar][:placeholder]
      # end

      # @contacts_search_display_controller = UISearchDisplayController.alloc.initWithSearchBar(search_bar, contentsController: params[:content_controller])
      # @contacts_search_display_controller.delegate = params[:delegate]
      # @contacts_search_display_controller.searchResultsDataSource = params[:data_source]
      # @contacts_search_display_controller.searchResultsDelegate = params[:search_results_delegate]

      # self.table_view.tableHeaderView = search_bar
    end
    alias :makeRefreshable :make_refreshable

    ######### iOS methods, headless camel case #######

    # UIRefreshControl Delegates
    def refreshView(refresh)
      refresh.attributedTitle = NSAttributedString.alloc.initWithString("Refreshing data...")
      @on_refresh.call if @on_refresh
    end

    def on_refresh(&block)
      @on_refresh = block
    end

    def end_refreshing
      return unless @refresh

      @refresh.attributedTitle = NSAttributedString.alloc.initWithString("Last updated on #{Time.now.strftime("%H:%M:%S")}")
      @refresh.endRefreshing
      self.update_table_data
    end
  end
end