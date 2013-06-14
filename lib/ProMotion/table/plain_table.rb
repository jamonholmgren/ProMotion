module ProMotion
  module PlainTable
    include Table
    include SearchableTable
    include RefreshableTable

    def table_view
      @table_view ||= begin
        t = UITableView.alloc.initWithFrame(self.view.frame, style:UITableViewStylePlain)
        t.dataSource = self
        t.delegate = self
        t
      end
    end
    alias :tableView :table_view
  end
end
