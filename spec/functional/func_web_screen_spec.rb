describe "ProMotion::TestWebScreen functionality" do
  # NOTE: webstub doesn't support stubbing WKWebView requests
  # extend WebStub::SpecHelpers

  before do
    # disable_network_access!
    UIView.setAnimationDuration 0.01
  end
  # after { enable_network_access! }

  def controller
    @controller ||= TestWebScreen.new(nav_bar: true)
  end

  after do
    @controller = nil
  end

  it "should have the proper html content" do
    file_name = "WebScreen.html"

    controller.mock!(:navigation_finished) do |nav|
      loaded_file = File.read(File.join(NSBundle.mainBundle.resourcePath, file_name))
      controller.html do |html|
        html.should.not.be.nil
        html.delete("\n").should == loaded_file.delete("\n")
        resume
      end
    end
    controller.set_content(file_name)
    wait_max 8 {}
  end

  it "should allow you to navigate to a website" do
    # NOTE: webstub can't stub WKWebView requests
    # stub_request(:get, "https://www.google.com/").
    #   to_return(body: %q{Google! <form action="/search">%}, content_type: "text/html")

    controller.mock!(:navigation_finished) do |nav|
      controller.html do |html|
        html.should.include('<form action="/search"')
        resume
      end
    end
    controller.open_url('https://www.google.com/') # LIVE request!
    wait_max 8 {}
  end

  it "should manipulate the webscreen contents with javascript" do
    controller.mock!(:navigation_finished) do |nav|
      controller.evaluate_async('document.getElementById("cool").innerHTML = "Changed"') do |result, error|
        controller.html do |html|
          html.should =~ /<h1 id="cool">Changed<\/h1>/
          resume
        end
      end
    end
    controller.set_content('<h1 id="cool">Something Cool</h1>')
    wait_max 8 {}
  end

end
