module ProMotion::MotionTable
  module GroupedTable
    include SectionedTable
    include RefreshableTable

    def table_view
      @table_view ||= UITableView.alloc.initWithFrame(self.view.frame, style:UITableViewStyleGrouped)
      @table_view.dataSource = self;
      @table_view.delegate = self;
      return @table_view
    end
    alias :tableView :table_view
  end
end