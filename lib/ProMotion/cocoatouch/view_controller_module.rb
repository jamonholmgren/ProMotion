module ProMotion
  module ViewControllerModule
    def pm_main_controller
      navigationController || self
    end
    alias_method :main_controller, :pm_main_controller
  end
end

UIViewController.send :include, ProMotion::ViewControllerModule
