module ProMotion
  class Delegate

    include ProMotion::ScreenTabs
    include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2") # Only with iPad
    include DelegateHelper
    include DelegateNotifications
    
    attr_accessor :window, :aps_notification

    def application(application, didFinishLaunchingWithOptions:launch_options)
      
      apply_status_bar
      
      on_load application, launch_options

      check_for_notification launch_options
      
      true
      
    end

  end
  
  class AppDelegateParent < Delegate
    def self.inherited(klass)
      PM.logger.deprecated "PM::AppDelegateParent is deprecated. Use PM::Delegate."
    end
  end
end
