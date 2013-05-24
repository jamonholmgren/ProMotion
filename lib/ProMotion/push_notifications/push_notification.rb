module ProMotion
  class PushNotification
    
    attr_accessor :notification
    
    def initialize(n)
      self.notification = n
    end
    
    def to_s
      self.notification.inspect
    end
    
    def to_json
      PM.logger.warn "PM::PushNotification.to_json not implemented yet."
    end
    
    def aps
      self.notification["aps"]
    end
    
    def alert
      aps["alert"] if aps
    end
    
    def badge
      aps["badge"] if aps
    end
    
    def sound
      aps["sound"] if aps
    end
    
    # For testing from the REPL
    # > PM::PushNotification.simulate alert: "My test message", badge: 4
    def self.simulate(args = {})
      UIApplication.sharedApplication.delegate.on_notification self.fake_notification(args)
    end
    
    def self.fake_notification(args = {})
      self.new({
        "aps" => {
          "alert" => args[:alert] || "Test Push Notification",
          "badge" => args[:badge] || 2,
          "sound" => args[:sound] || "default"
        }
      })
    end
    
  end
end
