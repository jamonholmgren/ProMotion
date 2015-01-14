describe "PM::Support" do

  before do
    @app = TestDelegate.new
    @screen = BasicScreen.new
  end

  it "has a convenience method for UIApplication.sharedApplication" do
    @app.app.should == UIApplication.sharedApplication
    @screen.app.should == UIApplication.sharedApplication
  end

  it "has a convenience method for UIApplication.sharedApplication.delegate" do
    @app.app_delegate.should == UIApplication.sharedApplication.delegate
    @screen.app_delegate.should == UIApplication.sharedApplication.delegate
  end

  it "has a convenience method for UIApplication.sharedApplication.delegate.window" do
    @app.app_window.should == UIApplication.sharedApplication.delegate.window
    @screen.app_window.should == UIApplication.sharedApplication.delegate.window
  end

end


