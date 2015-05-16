module ProMotion
  module WebScreenModule

    attr_accessor :webview, :external_links, :detector_types, :scale_to_fit

    def screen_setup
      check_content_data
      self.external_links ||= false
      self.scale_to_fit ||= false
      self.detector_types ||= :none

      web_view_setup
      set_initial_content
    end

    def on_init
      # TODO: Remove in 3.0
    end

    def web_view_setup
      self.webview ||= add UIWebView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        delegate: self,
        data_detector_types: data_detector_types
      }
      self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.webview.scalesPageToFit = self.scale_to_fit
      self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    end

    def web
      self.webview
    end

    def set_initial_content
      return unless self.respond_to?(:content) && self.content
      self.content.is_a?(NSURL) ? open_url(self.content) : set_content(self.content)
    end

    def set_content(content)
      content_path = File.join(NSBundle.mainBundle.resourcePath, content)

      if File.exists? content_path
        content_string = File.read content_path
        content_base_url = NSURL.fileURLWithPath NSBundle.mainBundle.resourcePath

        self.web.loadHTMLString(convert_retina_images(content_string), baseURL:content_base_url)
      else
        # We assume the user wants to load an arbitrary string into the web view
        self.web.loadHTMLString(content, baseURL:nil)
      end
    end

    def open_url(url)
      request = NSURLRequest.requestWithURL(
        url.is_a?(NSURL) ? url : NSURL.URLWithString(url)
      )
      web.loadRequest request
    end

    def convert_retina_images(content)
      #Convert images over to retina if the images exist.
      if UIScreen.mainScreen.bounds.respondsToSelector('displayLinkWithTarget:selector:') && UIScreen.mainScreen.bounds.scale == 2.0 # Thanks BubbleWrap! https://github.com/rubymotion/BubbleWrap/blob/master/motion/core/device/ios/screen.rb#L9
        content.gsub!(/src=['"](.*?)\.(jpg|gif|png)['"]/) do |img|
          if File.exists?(File.join(NSBundle.mainBundle.resourcePath, "#{$1}@2x.#{$2}"))
            # Create a UIImage to get the width and height of hte @2x image
            tmp_image = UIImage.imageNamed("/#{$1}@2x.#{$2}")
            new_width = tmp_image.size.width / 2
            new_height = tmp_image.size.height / 2

            img = "src=\"#{$1}@2x.#{$2}\" width=\"#{new_width}\" height=\"#{new_height}\""
          end
        end
      end
      content
    end

    def check_content_data
      mp("Missing #content method in WebScreen #{self.class.to_s}.", force_color: :red) unless self.respond_to?(:content)
    end

    def html
      evaluate("document.documentElement.outerHTML")
    end

    def evaluate(js)
      self.webview.stringByEvaluatingJavaScriptFromString(js)
    end

    def current_url
      evaluate('document.URL')
    end

    # Navigation
    def can_go_back; web.canGoBack; end
    def can_go_forward; web.canGoForward; end
    def back; web.goBack if can_go_back; end
    def forward; web.goForward if can_go_forward; end
    def refresh; web.reload; end
    def stop; web.stopLoading; end
    alias :reload :refresh

    def open_in_chrome(in_request)
      # Add pod 'OpenInChrome' to your Rakefile if you want links to open in Google Chrome for users.
      # This will fall back to Safari if the user doesn't have Chrome installed.
      chrome_controller = OpenInChromeController.sharedInstance
      return open_in_safari(in_request) unless chrome_controller.isChromeInstalled
      chrome_controller.openInChrome(in_request.URL)
    end

    def open_in_safari(in_request)
      # Open UIWebView delegate links in Safari.
      UIApplication.sharedApplication.openURL(in_request.URL)
    end

    # UIWebViewDelegate Methods - Camelcase
    def webView(in_web, shouldStartLoadWithRequest:in_request, navigationType:in_type)
      if %w(http https).include?(in_request.URL.scheme)
        if self.external_links == true && in_type == UIWebViewNavigationTypeLinkClicked
          if defined?(OpenInChromeController)
            open_in_chrome in_request
          else
            open_in_safari in_request
          end
          return false # don't allow the web view to load the link.
        end
      end

      load_request_enable = true #return true on default for local file loading.
      load_request_enable = !!on_request(in_request, in_type) if self.respond_to?(:on_request)
      load_request_enable
    end

    def webViewDidStartLoad(webView)
      load_started if self.respond_to?(:load_started)
    end

    def webViewDidFinishLoad(webView)
      load_finished if self.respond_to?(:load_finished)
    end

    def webView(webView, didFailLoadWithError:error)
      load_failed(error) if self.respond_to?("load_failed:")
    end

    protected

    def data_detector_types
      Array(self.detector_types).reduce(UIDataDetectorTypeNone) do |detectors, dt|
        detectors | map_detector_symbol(dt)
      end
    end

    def map_detector_symbol(symbol)
      {
        phone:    UIDataDetectorTypePhoneNumber,
        link:     UIDataDetectorTypeLink,
        address:  UIDataDetectorTypeAddress,
        event:    UIDataDetectorTypeCalendarEvent,
        all:      UIDataDetectorTypeAll
      }[symbol] || UIDataDetectorTypeNone
    end

  end
end
