module ProMotion
  class Screen < ViewController
    # You can inherit a screen from any UIViewController if you include the ScreenViewController module
    # Just make sure to implement the Obj-C methods in _cocoatouch/ViewController.rb.
    include ProMotion::ScreenModule
  end
end