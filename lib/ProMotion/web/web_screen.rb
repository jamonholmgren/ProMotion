module ProMotion
  # requires class:ViewController
  class WebScreen < ViewController
    # requires module:ScreenModule
    include ProMotion::ScreenModule
    # requires module:WebScreenModule
    include ProMotion::WebScreenModule
  end
end
