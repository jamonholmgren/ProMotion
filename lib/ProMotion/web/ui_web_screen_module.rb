module ProMotion
  module UIWebScreenModule
    def web_view_setup
      self.webview = add UIWebView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        delegate: self,
        data_detector_types: data_detector_types
      }

      self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.webview.scalesPageToFit = self.scale_to_fit
      self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    end

    def evaluate(js)
      self.webview.stringByEvaluatingJavaScriptFromString(js)
    end

    def evaluate_async(js, &block)
      Dispatch::Queue.concurrent.async do
        result = evaluate(js)
        Dispatch::Queue.main.async do
          block.call result
        end
      end
    end

    def go_to_item(item)
      # self.webview.goToBackForwardListItem(item)
      PM.logger.warn "`go_to_item` is not implemented with the older UIWebView, which doesn't support it."
      false
    end

    def back_forward_list
      # self.webview.backForwardList
      PM.logger.warn "`back_forward_list` is not implemented with the older UIWebView, which doesn't support it."
      false
    end

    def progress
      # self.webview.estimatedProgress
      PM.logger.warn "`progress` is not implemented with the older UIWebView, which doesn't support it."
      false
    end

    # CocoaTouch methods

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

  end
end
