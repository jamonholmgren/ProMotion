module ProMotion::MotionTable
  module RefreshableTable
    def make_refreshable(params={})
      pull_message = params[:pull_message] || "Pull to refresh"
      @refreshing = params[:refreshing] || "Refreshing data..."
      @updated_format = params[:updated_format] || "Last updated at %s"
      @updated_time_format = params[:updated_time_format] || "%l:%M %p"
      @refreshable_callback = params[:callback]

      @refresh = UIRefreshControl.alloc.init
      @refresh.attributedTitle = NSAttributedString.alloc.initWithString(pull_message)
      @refresh.addTarget(self, action:'refreshView:', forControlEvents:UIControlEventValueChanged)
      self.refreshControl = @refresh
    end
    alias :makeRefreshable :make_refreshable

    ######### iOS methods, headless camel case #######

    # UIRefreshControl Delegates
    def refreshView(refresh)
      refresh.attributedTitle = NSAttributedString.alloc.initWithString(@refreshing)
      if @refreshable_callback && self.respond_to?(@refreshable_callback)
        self.send(@refreshable_callback)
      else
          ProMotion::Console.log("ProMotion Warning: you must implement an on_refresh method in your TableScreen.", with_color: ProMotion::Console::RED_COLOR)
      end
    end

    def start_refreshing
      return unless @refresh

      @refresh.beginRefreshing
    end

    def end_refreshing
      return unless @refresh

      @refresh.attributedTitle = NSAttributedString.alloc.initWithString(sprintf(@updated_format, Time.now.strftime(@updated_time_format)))
      @refresh.endRefreshing
    end
  end
end