module ProMotion
  # @requires class:DelegateParent
  class Delegate < DelegateParent
    # @requires module:DelegateModule
    include ProMotion::DelegateModule
  end
end
