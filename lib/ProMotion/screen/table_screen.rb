module ProMotion
  # Instance methods
  class TableScreen < TableViewController
    include ProMotion::TableScreenModule
  end

  class GroupedTableScreen < TableScreen
    include ProMotion::MotionTable::GroupedTable
  end

  class SectionedTableScreen < TableScreen
    include ProMotion::MotionTable::SectionedTable
  end
end