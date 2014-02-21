motion_require '../cocoatouch/table_view_controller'
motion_require '../screen/screen_module'
motion_require 'table'
motion_require 'grouped_table'

module ProMotion
  class GroupedTableScreen < TableViewController
    include ProMotion::ScreenModule
    include ProMotion::Table
    include ProMotion::GroupedTable
  end
end
