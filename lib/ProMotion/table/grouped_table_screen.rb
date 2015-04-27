module ProMotion
  class GroupedTableScreen < TableViewController
    include ProMotion::ScreenModule
    include ProMotion::TableBuilder
    include ProMotion::Table
    include ProMotion::Table::Utils # Workaround until https://hipbyte.freshdesk.com/support/tickets/2086 is fixed.
    include ProMotion::GroupedTable
  end
end
