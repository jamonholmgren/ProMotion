module ProMotion
  module GroupedTable
    include ProMotion::Table
    
    def table_style
      UITableViewStyleGrouped
    end
  end
end
