describe "web screen properties" do
  extend WebStub::SpecHelpers

  before  { disable_network_access! }
  after   { enable_network_access! }

  it "should leave on_init available as a hook" do
    webscreen = TestWebScreen.new()
    webscreen.on_init_available?.should == true
  end

  describe "when open web page with http request" do
    before do
      class TestWebScreenWithHTTPRequest < TestWebScreen
        attr_accessor :on_request, :on_request_args
        def on_request(request, type)
          self.on_request_args = [request, type]
          self.on_request = true
        end
      end
      stub_request(:get, "http://mixi.jp/").
        to_return(body: "<html><body>[mixi]</body></html>", content_type: "text/html")
      # Simulate AppDelegate setup of web screen
      @webscreen = TestWebScreenWithHTTPRequest.new modal: true, nav_bar: true, external_links: false
    end

    it "should get the current url" do
      @webscreen.open_url(NSURL.URLWithString('http://mixi.jp/'))

      wait_for_change @webscreen, 'is_load_finished' do
        @webscreen.current_url.should == 'http://mixi.jp/'
      end
    end
    
    it "should open web page via NSMutableURLRequest" do
      nsurl = NSURL.URLWithString('http://mixi.jp/')
      @webscreen.web.loadRequest NSMutableURLRequest.requestWithURL(nsurl)

      wait_for_change @webscreen, 'is_load_finished' do
        @webscreen.current_url.should == 'http://mixi.jp/'
      end
    end

    it "should open web page by url string" do
      @webscreen.open_url('http://mixi.jp/')
      wait_for_change @webscreen, 'is_load_finished' do
        @webscreen.html.should =~ /mixi/
      end
    end

    it "should call on_request hook" do
      @webscreen.open_url(NSURL.URLWithString('http://mixi.jp/'))

      wait_for_change @webscreen, 'on_request' do
        @webscreen.on_request_args[0].is_a?(NSURLRequest).should == true
        # on_request is called when @webscreen request for some iframe
        @webscreen.on_request_args[0].URL.absoluteString.should =~ %r|https?://.*|
      end
    end

  end

  describe "when loading a static html file" do
    before do
      # Simulate AppDelegate setup of web screen
      @webscreen = TestWebScreen.new modal: true, nav_bar: true, external_links: false
      @webscreen.set_content("WebScreen.html")
    end

    it "should get the url of content" do
      @webscreen.current_url.should == 'about:blank'
    end

    it "should have a UIWebView as the primary view" do
      @webscreen.web.class.should == UIWebView
    end

    it "should load the about html page" do
      wait_for_change @webscreen, 'is_load_finished' do
        @webscreen.is_load_finished.should == true
      end
    end
  end

  describe "when setting attributes" do
    it "should have a default values" do
      webscreen = TestWebScreen.new()
      webscreen.web.dataDetectorTypes.should == UIDataDetectorTypeNone
      webscreen.web.scalesPageToFit.should == false
      webscreen.external_links.should == false
    end

    it "should set a single data detector" do
      webscreen = TestWebScreen.new(detector_types: :phone)
      webscreen.web.dataDetectorTypes.should == UIDataDetectorTypePhoneNumber
    end

    it "should set multiple data detectors" do
      webscreen = TestWebScreen.new(detector_types: [:phone, :link])
      webscreen.web.dataDetectorTypes.should == UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink
    end

    it "should set the scaling mode of the screen" do
      webscreen = TestWebScreen.new(scale_to_fit: true)
      webscreen.web.scalesPageToFit.should == true
    end

    it "should have the ability to open links externally" do
      webscreen = TestWebScreen.new(external_links: true)
      webscreen.external_links.should == true
    end
  end

end
