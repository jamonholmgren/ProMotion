describe "web screen properties" do
  # NOTE: webstub doesn't work with WKWebView
  # extend WebStub::SpecHelpers
  # before { disable_network_access! }
  # after  { enable_network_access! }

  it "should leave on_init available as a hook" do
    webscreen = TestWebScreen.new
    webscreen.on_init_available?.should == true
  end

  it "can perform asynchronous javascript execution" do
    webscreen = TestWebScreen.new
    js = 'document.documentElement.innerHTML = "test"; document.documentElement.outerHTML'
    webscreen.evaluate_async(js) do |result, error|
      result.should == '<html><head></head><body>test</body></html>'
      resume
    end
    wait_max 2 {}
  end

  it "can perform synchronous javascript execution" do
    webscreen = TestWebScreen.new
    js = 'document.documentElement.innerHTML = "test"; document.documentElement.outerHTML'
    wait_max(2) do
      result = webscreen.evaluate(js)
      result.should == '<html><head></head><body>test</body></html>'
    end
  end

  describe "opening a web page using an http request" do
    before do
      class TestWebScreenWithHTTPRequest < TestWebScreen
        attr_accessor :on_request_called, :on_request_args
        # NOTE: this hook is for deciding whether or not the request should continue
        def on_request(request, type)
          self.on_request_args = [request, type]
          self.on_request_called = true
          false # cancel request since we can't stub it
        end
      end
      
      # NOTE: webstub doesn't support stubbing WKWebView requests
      #stub_request(:get, "https://mixi.jp/").
      #  to_return(body: "<html><body>[mixi]</body></html>", content_type: "text/html")

      # Simulate AppDelegate setup of web screen
      @webscreen = TestWebScreenWithHTTPRequest.new modal: true, nav_bar: true, external_links: false
    end
    
    it "should call on_request hook" do
      @webscreen.open_url('https://mixi.jp/')

      wait_for_change @webscreen, 'on_request_called' do
        @webscreen.on_request_called.should == true
      end
    end
    
    it "should open web page via NSMutableURLRequest" do
      nsurl = NSURL.URLWithString('https://mixi.jp/')
      @webscreen.web.loadRequest NSMutableURLRequest.requestWithURL(nsurl)

      wait_for_change @webscreen, 'on_request_called' do
        request = @webscreen.on_request_args.first
        request.should.be.a.kind_of NSURLRequest
        request.URL.absoluteString.should == 'https://mixi.jp/'
      end
    end

    it "should open web page by url string" do
      @webscreen.open_url('https://mixi.jp/')

      wait_for_change @webscreen, 'on_request_called' do
        request = @webscreen.on_request_args.first
        request.should.be.a.kind_of NSURLRequest
        request.URL.absoluteString.should == 'https://mixi.jp/'
      end
    end

    # TODO: these features used to be supported prior to WKWebView migration
    # it "can synchronously return the current page html"
    # it "can synchronously return the current page url"
  end

  describe "when loading a static html file" do
    before do
      # Simulate AppDelegate setup of web screen
      @webscreen = TestWebScreen.new modal: true, nav_bar: true, external_links: false
      @webscreen.set_content("WebScreen.html")
    end

    it "should get the url of content" do
      @webscreen.current_url do |url|
        url.should == 'about:blank'
        resume
      end
      wait_max 1 {}
    end

    it "should have a WKWebView as the primary view" do
      @webscreen.web.class.should == WKWebView
    end

    it "should load the about html page" do
      wait_for_change @webscreen, 'is_nav_finished', 3 do
        @webscreen.is_nav_finished.should == true
      end
    end
  end

  describe "when setting attributes" do
    it "should have a default values" do
      webscreen = TestWebScreen.new()
      webscreen.web.configuration.dataDetectorTypes.should == UIDataDetectorTypeNone
      webscreen.external_links.should == false
    end

# FIXME: these should work after getting initWithFrame:configuration: to work.
#    it "should set a single data detector" do
#      webscreen = TestWebScreen.new(detector_types: :phone)
#      webscreen.web.configuration.dataDetectorTypes.should == UIDataDetectorTypePhoneNumber
#    end

#    it "should set multiple data detectors" do
#      webscreen = TestWebScreen.new(detector_types: [:phone, :link])
#      webscreen.web.configuration.dataDetectorTypes.should == UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink
#    end

    it "should have the ability to open links externally" do
      webscreen = TestWebScreen.new(external_links: true)
      webscreen.external_links.should == true
      # TODO: test that link click opens Safari
    end
  end

end
