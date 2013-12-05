motion_require '../cocoatouch/view_controller'
motion_require 'screen_module'

module ProMotion
  class Screen < ViewController
    # You can inherit a screen from any UIViewController if you include the ScreenModule
    # Just make sure to implement the Obj-C methods in cocoatouch/view_controller.rb.
    include ProMotion::ScreenModule
  end
end
