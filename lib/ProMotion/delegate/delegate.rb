module ProMotion
  class Delegate

    include ProMotion::ScreenTabs
    include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2") # Only with iPad
    include DelegateHelper
    include DelegateNotifications
    
  end
  
  class AppDelegateParent < Delegate
    def self.inherited(klass)
      PM.logger.deprecated "PM::AppDelegateParent is deprecated. Use PM::Delegate."
    end
  end
end
