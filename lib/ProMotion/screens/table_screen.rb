module ProMotion
  # You can inherit a table screen from any UITableViewController if you include TableScreenModule
  # Just make sure to implement the Obj-C methods in cocoatouch/TableViewController.rb.
  class TableScreen < TableViewController
    include ProMotion::TableScreenModule
    extend ProMotion::NotificationCenterCallback
  end

  class GroupedTableScreen < TableScreen
    include ProMotion::MotionTable::GroupedTable
    extend ProMotion::NotificationCenterCallback
  end

  class SectionedTableScreen < TableScreen
    include ProMotion::MotionTable::SectionedTable
    extend ProMotion::NotificationCenterCallback
  end
end