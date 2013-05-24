class Something
  WORTH_WATCHING = 'NSSomethingWorthWatching'
end
class NotificationCenterScreen < PM::Screen
  title "Notification Center"
  observe Something::WORTH_WATCHING, :talk_about_it

  def has_changed?
    @changed ||= false
  end

  def talk_about_it(notification)
    @changed = true 
  end

  def will_appear
    set_attributes self.view, {
      backgroundColor: UIColor.whiteColor
    }
    button = add UIButton.buttonWithType(UIButtonTypeRoundedRect), {}
    button.setTitle "Open Modal", forState: UIControlStateNormal
    button.sizeToFit
    button.frame = [[0,0],button.frame.size]
    button.addTarget self, action: "open_modal", forControlEvents: UIControlEventTouchUpInside
  end

  def open_modal
    open NotificationModalScreen.new, modal: true
  end

end
