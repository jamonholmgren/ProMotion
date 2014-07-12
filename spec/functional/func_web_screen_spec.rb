describe "ProMotion::TestWebScreen functionality" do
  extend WebStub::SpecHelpers

  before  { disable_network_access! }
  after   { enable_network_access! }

  def controller
    @controller ||= TestWebScreen.new(nav_bar: true)
  end

  after do
    @controller = nil
  end

  it "should have the proper html content" do
    file_name = "WebScreen.html"

    controller.set_content(file_name)

    @loaded_file = File.read(File.join(NSBundle.mainBundle.resourcePath, file_name))
    wait_for_change controller, 'is_load_finished' do
      controller.html.delete("\n").should == @loaded_file.delete("\n")
    end
  end

  it "should allow you to navigate to a website" do
    stub_request(:get, "https://www.google.com/").
      to_return(body: %q{Google! <form action="/search">%}, content_type: "text/html")

    controller.open_url(NSURL.URLWithString("https://www.google.com/"))
    wait_for_change controller, 'is_load_finished' do
      controller.html.include?('<form action="/search"').should == true
    end
  end

  it "should manipulate the webscreen contents with javascript" do
    controller.set_content('<h1 id="cool">Something Cool</h1>')

    wait_for_change controller, 'is_load_finished' do
      controller.evaluate('document.getElementById("cool").innerHTML = "Changed"')
      controller.html.should =~ /<h1 id="cool">Changed<\/h1>/
    end

  end

end
