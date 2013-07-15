describe "web screen properties" do
  extend WebStub::SpecHelpers

  before  { disable_network_access! }
  after   { enable_network_access! }

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

      wait_for_change @webscreen, 'load_finished' do
        @webscreen.current_url.should == 'http://mixi.jp/'
      end
    end

    it "should open web page by url string" do
      @webscreen.open_url('http://mixi.jp/')
      wait_for_change @webscreen, 'load_finished' do
        @webscreen.html.should =~ /mixi/
      end
    end

    it "should called on_request hook" do
      @webscreen.open_url(NSURL.URLWithString('http://mixi.jp/'))

      wait_for_change @webscreen, 'on_request' do
        @webscreen.on_request_args[0].is_a?(NSURLRequest).should == true
        # on_request is called when @webscreen request for some iframe
        @webscreen.on_request_args[0].URL.absoluteString.should =~ %r|https?://.*|
      end
    end

  end

  describe "when use on_request hook by web brigde rpc" do
    before do
      class TestWebScreenWithRPC < TestWebScreen
        attr_accessor :on_request, :on_request_args

        def on_request(request, type)
          self.on_request_args = [request, type]
          self.on_request = true
          # return false to prevent loadRequest
          false
        end
      end
      stub_request(:get, "http://mixi.jp/").
        to_return(body: "<html><body>[mixi]</body></html>", content_type: "text/html")
      # Simulate AppDelegate setup of web screen
      @webscreen = TestWebScreenWithRPC.new modal: true, nav_bar: true, external_links: false
    end

    it "should called on_request hook" do
      # simulate web bridge request from html links
      @webscreen.open_url(NSURL.URLWithString('webbridge://method'))

      wait_for_change @webscreen, 'on_request' do
        request = @webscreen.on_request_args[0]
        # on_request is called when @webscreen request for some iframe
        request.URL.absoluteString.should == 'webbridge://method'
      end

      wait 0.3 do
        # it should not load request when return false in on_request
        !!(@webscreen.load_finished.should) == false
      end
    end
  end

  describe "when load static html file" do
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
      wait_for_change @webscreen, 'load_finished' do
        @webscreen.load_finished.should == true
      end
    end
  end

end
