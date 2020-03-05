module ProMotion
  module WKWebScreenModule
    def web_view_setup
      configuration = WKWebViewConfiguration.alloc.init
      configuration.dataDetectorTypes = data_detector_types
      frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
      # FIXME: get this working: wkwebview = WKWebView.alloc.initWithFrame(frame, configuration: configuration)
      wkwebview = WKWebView.alloc.initWithFrame(frame)
      self.webview = add(wkwebview)
      self.webview.UIDelegate = self
      self.webview.navigationDelegate = self
      self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    end

    def evaluate(js, &block)
      if block
        evaluate_async(js) do |result, error|
          block.call(result) # ignore error
        end
        return
      end
      res = nil
      semaphore = Dispatch::Semaphore.new(0)
      # FIXME: this  blocks and never returns
      evaluate_async(js) do |result, error|
        res = result
        semaphore.signal
      end
      semaphore.wait(Dispatch::TIME_FOREVER)
      return res
    end

    def evaluate_async(js, &block)
      self.webview.evaluateJavaScript(js, completionHandler: -> (result, error) {
        block.call(result, error)
      })
    end

    def go_to_item(item)
      self.webview.goToBackForwardListItem(item)
    end

    def back_forward_list
      self.webview.backForwardList
    end

    def progress
      self.webview.estimatedProgress
    end

    # CocoaTouch methods

    def webView(view, decidePolicyForNavigationAction: navigationAction, decisionHandler: decisionHandler)
      request = navigationAction.request
      nav_type = navigationAction.navigationType
      
      if %w(http https).include?(request.URL.scheme)
        if self.external_links == true && nav_type == WKNavigationTypeLinkActivated
          if defined?(OpenInChromeController)
            open_in_chrome(request)
          else
            open_in_safari(request)
          end
          decisionHandler.call(WKNavigationActionPolicyCancel) # don't allow the web view to load the link
          return
        end
      end
      
      load_request_enable = true # return true by default for local file loading
      load_request_enable = !!on_request(request, nav_type) if self.respond_to?(:on_request)
      decisionHandler.call(load_request_enable ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel)
    end
    
    def webView(view, didCommitNavigation: navigation)
      navigation_started(navigation) if self.respond_to?("navigation_started")
    end

    def webView(view, didFailNavigation: navigation, withError: error)
      navigation_failed(navigation, error) if self.respond_to?("navigation_failed")
    end

    def webView(view, didFinishNavigation: navigation)
      navigation_finished(navigation) if self.respond_to?("navigation_finished")
    end
  end
end
