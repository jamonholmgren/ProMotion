# requires class:ProMotion::ViewController
# requires module:ProMotion::ScreenModule
# requires module:ProMotion::MapScreenModule
module ProMotion
  class MapScreen < ViewController
    include ProMotion::ScreenModule
    include ProMotion::MapScreenModule
  end
end
