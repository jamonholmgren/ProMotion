module ProMotion
  module Table
    module Refreshable
      def make_refreshable(params={})
        pull_message = params[:pull_message] || "Pull to refresh"
        @refreshing = params[:refreshing] || "Refreshing data..."
        @updated_format = params[:updated_format] || "Last updated at %s"
        @updated_time_format = params[:updated_time_format] || "%l:%M %p"
        @refreshable_callback = params[:callback] || :on_refresh

        @refresh_control = UIRefreshControl.alloc.init
        @refresh_control.attributedTitle = NSAttributedString.alloc.initWithString(pull_message)
        @refresh_control.addTarget(self, action:'refreshView:', forControlEvents:UIControlEventValueChanged)
        self.refreshControl = @refresh_control
      end

      def start_refreshing
        return unless @refresh_control

        @refresh_control.beginRefreshing

        # Fix iOS 7 now showing the spinner automatically when beginRefreshing is called
        # Modification of this code: http://stackoverflow.com/a/16250679/814123
        if self.tableView.contentOffset.y < 0 && UIDevice.currentDevice.systemVersion.to_f >= 7.0
          UIView.animateWithDuration(0.25, delay:0, options:UIViewAnimationOptionBeginFromCurrentState, animations: lambda {
            self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y - @refresh_control.frame.size.height)
          }, completion: lambda{|finished|
            # nada
          })
        end

      end
      alias :begin_refreshing :start_refreshing

      def end_refreshing
        return unless @refresh_control

        @refresh_control.attributedTitle = NSAttributedString.alloc.initWithString(sprintf(@updated_format, Time.now.strftime(@updated_time_format)))
        @refresh_control.endRefreshing
      end
      alias :stop_refreshing :end_refreshing

      ######### iOS methods, headless camel case #######

      # UIRefreshControl Delegates
      def refreshView(refresh)
        refresh.attributedTitle = NSAttributedString.alloc.initWithString(@refreshing)
        if @refreshable_callback && self.respond_to?(@refreshable_callback)
          self.send(@refreshable_callback)
        else
          PM.logger.warn "You must implement the '#{@refreshable_callback}' method in your TableScreen."
        end
      end
    end
  end
end
