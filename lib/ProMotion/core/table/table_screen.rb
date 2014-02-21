motion_require '../cocoatouch/table_view_controller'
motion_require '../screen/screen_module'
motion_require 'table'

module ProMotion
  class TableScreen < TableViewController
    include ProMotion::ScreenModule
    include ProMotion::Table
  end
end
