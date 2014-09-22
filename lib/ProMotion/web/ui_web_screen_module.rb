module ProMotion
  module UIWebScreenModule
    def build_web_view
      self.webview = add UIWebView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        delegate: self,
        data_detector_types: self.detector_types
      }

      self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.webview.scalesPageToFit = self.scale_to_fit
      self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    end

    def evaluate(js)
      self.webview.stringByEvaluatingJavaScriptFromString(js)
    end

    def webView(inWeb, shouldStartLoadWithRequest:inRequest, navigationType:inType)
      if self.external_links == true && inType == UIWebViewNavigationTypeLinkClicked
        if defined?(OpenInChromeController)
          open_in_chrome inRequest
        else
          open_in_safari inRequest
        end
        return false #don't allow the web view to load the link.
      end

      load_request_enable = true #return true on default for local file loading.
      load_request_enable = !!on_request(inRequest, inType) if self.respond_to?(:on_request)
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
  end
end
