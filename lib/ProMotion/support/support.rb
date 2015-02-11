module ProMotion
  module Support

    def app
      UIApplication.sharedApplication
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def app_window
      UIApplication.sharedApplication.delegate.window
    end

    def try(method, *args)
      send(method, *args) if respond_to?(method)
    end

  end
end
