module ProMotion::MotionTable
  module GroupedTable
    include ::ProMotion::MotionTable::SectionedTable
    
    def tableView
      @tableView ||= UITableView.alloc.initWithFrame(self.view.frame, style:UITableViewStyleGrouped)
      @tableView.dataSource = self;
      @tableView.delegate = self;
      return @tableView
    end
  end
end