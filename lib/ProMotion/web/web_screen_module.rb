module ProMotion
  module WebScreenModule
    include ProMotion::ViewHelper
    include ScreenModule

    attr_accessor :webview, :external_links, :detector_types

    def screen_setup
      check_content_data
      self.external_links ||= false
    end

    def on_init

      self.detector_types ||= UIDataDetectorTypeNone
      detectors = self.detector_types
      if self.detector_types.is_a? Array
        detectors |= UIDataDetectorTypePhoneNumber   if self.detector_types.include?(:phone)
        detectors |= UIDataDetectorTypeLink          if self.detector_types.include?(:link)
        detectors |= UIDataDetectorTypeAddress       if self.detector_types.include?(:address)
        detectors |= UIDataDetectorTypeCalendarEvent if self.detector_types.include?(:event)
        detectors |= UIDataDetectorTypeAll           if self.detector_types.include?(:all)
      end

      self.webview ||= add UIWebView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        resize: [ :width, :height ],
        delegate: self,
        data_detector_types: detector_types
      }

      set_initial_content
    end

    def web
      self.webview
    end

    def set_initial_content
      return unless self.respond_to?(:content)
      set_content(content)
    end

    def set_content(content)
      if content.is_a? NSURL
        initialize_with_url content
      else
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
    end

    def initialize_with_url(url)
      request = NSURLRequest.requestWithURL(url)
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
      PM.logger.error "Missing #content method in WebScreen #{self.class.to_s}." unless self.respond_to?(:content)
    end

    def html
      self.webview.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")
    end

    def evaluate(js)
      self.webview.stringByEvaluatingJavaScriptFromString(js)
    end

    def current_url
      evaluate('document.URL')
    end

    def open_url(url)
      ns_url = NSURL.URLWithString(url)
      set_content(ns_url)
    end

    # Navigation
    def can_go_back; web.canGoBack; end
    def can_go_forward; web.canGoForward; end
    def back; web.goBack if can_go_back; end
    def forward; web.goForward if can_go_forward; end
    def refresh; web.reload; end
    def stop; web.stopLoading; end
    alias :reload :refresh

    def open_in_chrome(inRequest)
      # Add pod 'OpenInChrome' to your Rakefile if you want links to open in chrom for users.
      chrome_controller = OpenInChromeController.sharedInstance
      return open_in_safari(inRequest) unless chrome_controller.isChromeInstalled
      chrome_controller.open_in_chrome(inRequest.URL)
    end

    def open_in_safari(inRequest)
      #Open UIWebView delegate links in Safari.
      UIApplication.sharedApplication.openURL(inRequest.URL)
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    #UIWebViewDelegate Methods - Camelcase
    def webView(inWeb, shouldStartLoadWithRequest:inRequest, navigationType:inType)
      if self.external_links == true && inType == UIWebViewNavigationTypeLinkClicked
        if defined?(OpenInChromeController)
          open_in_chrome inRequest
        else
          open_in_safari inRequest
        end
        return false #don't allow the web view to load the link.
      end
      true #return true for local file loading.
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

  end
end
