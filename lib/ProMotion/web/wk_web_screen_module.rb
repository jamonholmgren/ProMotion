module ProMotion
  module WKWebScreenModule
    def build_web_view
      self.webview = add WKWebView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        data_detector_types: self.detector_types
      }

      self.webview.UIDelegate = self
      self.webview.navigationDelegate = self
      self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
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

    def evaluate(js, &block)
      self.webview.evaluateJavaScript(js, completionHandler: -> (result, error) { 
        unless block.nil?
          block.call(result, error)
        end
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
  end
end
