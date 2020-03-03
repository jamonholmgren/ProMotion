module ProMotion
  module WKWebScreenModule
    def web_view_setup
      self.webview = add WKWebView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        data_detector_types: data_detector_types
      }

      self.webview.UIDelegate = self
      self.webview.navigationDelegate = self
      self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    end

    # `evaluate` will wait to return its payload
    # `evaluate_async` requires a block
    def evaluate(js)
      res = nil
      semaphore = Dispatch::Semaphore.new(0)
      evaluate_async do |result, error|
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
