module ProMotion
  class Screen < ViewController
    # You can inherit a screen from any UIViewController if you include the ScreenModule
    # Just make sure to implement the Obj-C methods in cocoatouch/ViewController.rb.
    include ProMotion::ScreenModule
  end
end
