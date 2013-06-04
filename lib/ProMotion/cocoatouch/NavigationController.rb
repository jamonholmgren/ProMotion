module ProMotion
	class NavigationController < UINavigationController
		def shouldAutorotate
			visibleViewController.shouldAutorotate
		end

		def supportedInterfaceOrientations
			visibleViewController.supportedInterfaceOrientations
		end

		def preferredInterfaceOrientationForPresentation
			visibleViewController.preferredInterfaceOrientationForPresentation
		end
	end
end
