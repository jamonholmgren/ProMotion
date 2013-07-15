module ProMotion
  # This is a workaround to a RubyMotion bug that displays an error message when calling
  # `super` from application:didFinishLaunchingWithOptions: (which you sometimes need to
  # do when using a custom AppDelegate parent class).
  # See issue: https://github.com/clearsightstudio/ProMotion/issues/116
  class DelegateParent
    def application(application, didFinishLaunchingWithOptions:options)
      true
    end
  end
end
