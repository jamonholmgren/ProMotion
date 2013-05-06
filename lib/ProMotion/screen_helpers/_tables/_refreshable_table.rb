module ProMotion::MotionTable
  module RefreshableTable
    def make_refreshable
      @refresh = UIRefreshControl.alloc.init
      @refresh.attributedTitle = NSAttributedString.alloc.initWithString("Pull to Refresh")
      @refresh.addTarget(self, action:'refreshView:', forControlEvents:UIControlEventValueChanged)
      self.refreshControl = @refresh
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