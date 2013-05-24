module ProMotion
  module DelegateNotifications
    
    attr_accessor :aps_notification
    
    def check_for_notification(options)
      if options && options[UIApplicationLaunchOptionsRemoteNotificationKey]
        received_notification options[UIApplicationLaunchOptionsRemoteNotificationKey]
      end
    end
    
    def register_for_notifications(*notification_types)
      notification_types = Array.new(notification_types)
      notification_types = [ :badge, :sound, :alert, :newsstand ] if notification_types.include?(:all)
      
      types = UIRemoteNotificationTypeNone
      types = types | UIRemoteNotificationTypeBadge if notification_types.include?(:badge)
      types = types | UIRemoteNotificationTypeSound if notification_types.include?(:sound)
      types = types | UIRemoteNotificationTypeAlert if notification_types.include?(:alert)
      types = types | UIRemoteNotificationTypeNewsstandContentAvailability if notification_types.include?(:newsstand)

      UIApplication.sharedApplication.registerForRemoteNotificationTypes types
    end
    
    def unregister_for_notifications
      UIApplication.sharedApplication.unregisterForRemoteNotifications
    end
    
    def registered_notifications
      mask = UIApplication.sharedApplication.enabledRemoteNotificationTypes
      types = []
      
      types << :badge     if mask & UIRemoteNotificationTypeBadge
      types << :sound     if mask & UIRemoteNotificationTypeSound
      types << :alert     if mask & UIRemoteNotificationTypeAlert
      types << :newsstand if mask & UIRemoteNotificationTypeNewsstandContentAvailability
      
      types
    end
    
    def received_notification(notification)
      @aps_notification = PM::PushNotification.new(notification)
      on_notification(@aps_notification) if respond_to?(:on_notification)
    end
    
    # CocoaTouch
    
    def application(application, didRegisterForRemoteNotificationsWithDeviceToken:device_token)
      on_registration(device_token, nil) if respond_to?(:on_registration)
    end
    
    def application(application, didFailToRegisterForRemoteNotificationsWithError:error)
      on_registration(nil, error) if respond_to?(:on_registration)
    end
    
    def application(application, didReceiveRemoteNotification:notification)
      received_notification(notification)
    end

  end
end