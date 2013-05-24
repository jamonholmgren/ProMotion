class NotificationModalScreen < ProMotion::Screen
  title 'I am modal'

  def dismiss_with_notification
    a = ''
    close notify: { name: Something::WORTH_WATCHING, object: a }
  end

end