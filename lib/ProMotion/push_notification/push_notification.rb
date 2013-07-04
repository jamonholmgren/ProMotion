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

    def method_missing(meth, *args, &block)
      aps[meth.to_s] || aps[meth.to_sym] || self.notification[meth.to_s] || self.notification[meth.to_sym] || super
    end

    # For testing from the REPL
    # > PM::PushNotification.simulate alert: "My test message", badge: 4
    def self.simulate(args = {})
      UIApplication.sharedApplication.delegate.on_push_notification self.fake_notification(args), args[:launched]
    end

    def self.fake_notification(args = {})
      self.new({
        "aps" => {
          "alert" => args.delete(:alert) || "Test Push Notification",
          "badge" => args.delete(:badge) || 2,
          "sound" => args.delete(:sound) || "default"
        },
        "channels" => args.delete(:channels) || [
          "channel_name"
        ]
      }.merge(args))
    end

  end
end
