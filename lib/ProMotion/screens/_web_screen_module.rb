module ProMotion
  module WebScreenModule
    include ProMotion::ViewHelper
    include ScreenModule

    attr_accessor :webview, :external_links

    def web_setup
      check_content_data
      self.external_links ||= false
    end

    def on_init
      self.webview ||= add UIWebView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        resize: [ :width, :height ],
        delegate: self
      }

      set_initial_content
    end

    def web
      self.webview
    end

    def set_initial_content
      return unless self.respond_to?(:content)

      if content.is_a?(String) && content.match(/^http/)
        initial_content = NSURL.urlWithStrong(content)
      else
        initial_content = content
      end

      if initial_content.is_a? NSURL
        initialize_with_url initial_content
      else
        content_path = File.join(NSBundle.mainBundle.resourcePath, initial_content)

        if File.exists? content_path
          content_string = File.read content_path
          content_base_url = NSURL.fileURLWithPath NSBundle.mainBundle.resourcePath

          web.loadHTMLString(convert_retina_images(content_string), baseURL:content_base_url)
        else
          # We assume the user wants to load an arbitrary string into the web view
          web.loadHTMLString(initial_content, baseURL:nil)
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

    # Navigation
    def can_go_back; web.canGoBack; end
    def can_go_forward; web.canGoForward; end
    def back; web.goBack if can_go_back; end
    def forward; web.goForward if can_go_forward; end
    def refresh; web.reload; end
    def stop; web.stopLoading; end
    alias :reload :refresh

    #UIWebViewDelegate Methods - Camelcase
    def webView(inWeb, shouldStartLoadWithRequest:inRequest, navigationType:inType)
      if self.external_links == true && inType == UIWebViewNavigationTypeLinkClicked
        #Open UIWebView delegate links in Safari.
        UIApplication.sharedApplication.openURL(inRequest.URL)
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

    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end
