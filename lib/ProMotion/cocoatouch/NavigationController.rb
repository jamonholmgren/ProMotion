module ProMotion
  class NavigationController < UINavigationController
    def shouldAutorotate
      visibleViewController.shouldAutorotate
    end
  end
end
