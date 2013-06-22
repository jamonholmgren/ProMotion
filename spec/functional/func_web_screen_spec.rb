describe "ProMotion::TestWebScreen functionality" do
  tests PM::TestWebScreen

  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @webscreen ||= TestWebScreen.new(nav_bar: true)
    @webscreen.navigation_controller
  end

  after do
    @webscreen = nil
  end

  it "should have the proper html content" do
    file_name = "WebScreen.html"

    @webscreen.set_content(file_name)

    @loaded_file = File.read(File.join(NSBundle.mainBundle.resourcePath, file_name))
    wait 0.75 do
      @webscreen.html.should == @loaded_file
    end
  end

  it "should allow you to navigate to a website" do
    @webscreen.set_content(NSURL.URLWithString("http://www.google.com"))
    wait 1.0 do
      @webscreen.html.include?('<form action="/search"').should == true
    end
  end

  it "should manipulate the webscreen contents with javascript" do
    @webscreen.set_content('<h1 id="cool">Something Cool</h1>')

    wait 0.5 do
      @webscreen.evaluate('document.getElementById("cool").innerHTML = "Changed"')
      @webscreen.html.should == '<h1 id="cool">Changed</h1>'
    end

  end

end
