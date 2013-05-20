module ProMotion
  module BehavesLikeScreen
    def pm_main_controller
      navigationController || self
    end
    alias_method :main_controller, :pm_main_controller
  end
end

UIViewController.send :include, ProMotion::BehavesLikeScreen
