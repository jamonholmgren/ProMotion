module ProMotion
  class Screen < ViewController
    # You can inherit a screen from any UIViewController if you include the ScreenViewController module
    include ProMotion::ScreenModule
  end
end