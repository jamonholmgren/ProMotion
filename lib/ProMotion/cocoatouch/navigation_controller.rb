module ProMotion
  class NavigationController < UINavigationController

    def popViewControllerAnimated(animated)
      super
      self.viewControllers.last.send(:on_back) if self.viewControllers.last.respond_to?(:on_back)
    end

    def shouldAutorotate
      visibleViewController.shouldAutorotate if visibleViewController
    end

    def supportedInterfaceOrientations
      visibleViewController.supportedInterfaceOrientations
    end

    def preferredInterfaceOrientationForPresentation
      visibleViewController.preferredInterfaceOrientationForPresentation
    end

    def prefersStatusBarHidden
      vc = visibleViewController || rootViewController
      return false unless vc.respond_to?(:prefersStatusBarHidden)
      PM.logger.debug "NC: #{vc.prefersStatusBarHidden}"
      vc.prefersStatusBarHidden
    end

  end
end
