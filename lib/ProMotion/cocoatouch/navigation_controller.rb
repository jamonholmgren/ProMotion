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
      return UIInterfaceOrientationMaskAll unless visibleViewController
      visibleViewController.supportedInterfaceOrientations
    end

    def preferredInterfaceOrientationForPresentation
      visibleViewController.preferredInterfaceOrientationForPresentation
    end

  end
end
