module ProMotion
	module BehavesLikeScreen
		def pm_main_controller
			respond_to?(:main_controller) ? main_controller : self
		end
	end
end

UIViewController.send :include, ProMotion::BehavesLikeScreen
