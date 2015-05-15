describe "ProMotion::TestWebScreen functionality" do
  extend WebStub::SpecHelpers

  before do
    disable_network_access!
    UIView.setAnimationDuration 0.01
  end
  after   { enable_network_access! }

  def controller
    @controller ||= TestWebScreen.new(nav_bar: true)
  end

  after do
    @controller = nil
  end

  it "should have the proper html content" do
    file_name = "WebScreen.html"

    controller.mock!(:load_finished) do
      loaded_file = File.read(File.join(NSBundle.mainBundle.resourcePath, file_name))
      controller.html.delete("\n").should == loaded_file.delete("\n")
      resume
    end
    controller.set_content(file_name)
    wait_max 8 {}
  end

  it "should allow you to navigate to a website" do
    stub_request(:get, "https://www.google.com/").
      to_return(body: %q{Google! <form action="/search">%}, content_type: "text/html")

    controller.mock!(:load_finished) do
      controller.html.should.include('<form action="/search"')
      resume
    end
    controller.open_url(NSURL.URLWithString("https://www.google.com/"))
    wait_max 8 {}
  end

  it "should manipulate the webscreen contents with javascript" do
    controller.mock!(:load_finished) do
      controller.evaluate('document.getElementById("cool").innerHTML = "Changed"')
      controller.html.should =~ /<h1 id="cool">Changed<\/h1>/
      resume
    end
    controller.set_content('<h1 id="cool">Something Cool</h1>')
    wait_max 8 {}
  end

end
