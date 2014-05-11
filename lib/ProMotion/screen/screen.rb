module ProMotion
# @requires class:ViewController
  class Screen < ViewController
    # You can inherit a screen from any UIViewController if you include the ScreenModule
    # Just make sure to implement the Obj-C methods in cocoatouch/view_controller.rb.
    # @requires module:ScreenModule
    include ProMotion::ScreenModule
  end
end
