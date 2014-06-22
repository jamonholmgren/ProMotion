module ProMotion
  class GroupedTableScreen < TableViewController
    include ProMotion::ScreenModule
    include ProMotion::Table
    include ProMotion::GroupedTable
  end
end
