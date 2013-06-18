describe "web screen properties" do

  before do
    # Simulate AppDelegate setup of map screen
    @webscreen = TestWebScreen.new modal: true, nav_bar: true, external_links: false
    @webscreen.set_content("WebScreen.html")
  end

  it "should have a UIWebView as the primary view" do
    @webscreen.web.class.should == UIWebView
  end

  it "should load the about html page" do
    wait 0.5 do
      @webscreen.load_finished.should == true
    end
  end

end
