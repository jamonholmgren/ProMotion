motion_require '../cocoatouch/view_controller'
motion_require '../screen/screen_module'
motion_require 'map_screen_module'

module ProMotion
  class MapScreen < ViewController
    include ProMotion::ScreenModule
    include ProMotion::MapScreenModule
  end
end
