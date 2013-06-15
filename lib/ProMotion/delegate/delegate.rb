module ProMotion
  class Delegate

    include ProMotion::Tabs
    include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2") # Only with iPad
    include ProMotion::DelegateHelper
    include ProMotion::DelegateNotifications

  end
end
