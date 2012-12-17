module ProMotion
  class Screen < UIViewController
    # You can inherit a screen from any UIViewController if you include the ScreenViewController module
    include ProMotion::ScreenModule
  end
end