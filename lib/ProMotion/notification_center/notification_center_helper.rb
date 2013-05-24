module ProMotion
  module NotificationCenterCallback
    def observers
      @observers ||= []
    end

    def observe(*args)
      observers << args
    end
  end
  module NotificationCenterHelper
    def active_observers
      @active_observers ||= []
    end
    def has_observers?
      @active_observers.any?
    end
    def notification_center_setup
      if self.class.respond_to?(:observers)
        self.class.observers.each do |observer|
          name = observer.shift
          callback, object = observer.reverse
          if callback.nil?
            warn "[CALLBACK ERROR] A method or proc must be provided for observer #{name}"
            next
          end
          callback = method(callback).to_proc unless callback.is_a? Proc
          observer = NSNotificationCenter.defaultCenter.addObserverForName(name, object:object, queue: NSOperationQueue.mainQueue, usingBlock:callback)
          active_observers << observer
        end
      end
    end
    def notification_center_teardown
      active_observers.each do |observer|
        NSNotificationCenter.defaultCenter.removeObserver(observer)
        active_observers.delete(observer)
      end
    end
    def post_notifications(notifications)
      unless notifications.nil?
        notifications = [notifications] unless notifications.is_a? Array
        notifications.each do |notification|
          notification[:object] ||= ""
          NSNotificationCenter.defaultCenter.postNotificationName(notification[:name], object: notification[:object], userInfo: notification[:user_info])
        end
      end
    end
  end
end