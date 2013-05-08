module ProMotion::MotionTable
  module PlainTable
    include SectionedTable
    include SearchableTable
    include RefreshableTable

    def table_view
      @table_view ||= UITableView.alloc.initWithFrame(self.view.frame, style:UITableViewStylePlain)
      @table_view.dataSource = self;
      @table_view.delegate = self;
      return @table_view
    end
    alias :tableView :table_view
  end
end