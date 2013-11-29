motion_require 'delegate_module'
motion_require 'delegate_parent'

module ProMotion
  class Delegate < DelegateParent
    include ProMotion::DelegateModule
  end
end
