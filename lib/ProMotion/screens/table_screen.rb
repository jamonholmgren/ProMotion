module ProMotion
  # You can inherit a table screen from any UITableViewController if you include TableScreenModule
  # Just make sure to implement the Obj-C methods in cocoatouch/TableViewController.rb.
  class TableScreen < TableViewController
    include ProMotion::TableScreenModule
    # Includes PM::PlainTable already
  end

  class GroupedTableScreen < TableScreen
    include ProMotion::GroupedTable
  end

  class SectionedTableScreen < TableScreen
    include ProMotion::SectionedTable
  end
end