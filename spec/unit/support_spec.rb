describe "PM::Support" do

  before do
    @app = TestDelegate.new
    @screen = BasicScreen.new
    @tab_screen = TabScreen.new
    @table_screen = TestTableScreen.new
    @web_screen = TestWebScreen.new
  end

  it "has a convenience method for UIApplication.sharedApplication" do
    @app.app.should == UIApplication.sharedApplication
    @screen.app.should == UIApplication.sharedApplication
    @tab_screen.app.should == UIApplication.sharedApplication
    @table_screen.app.should == UIApplication.sharedApplication
    @web_screen.app.should == UIApplication.sharedApplication
  end

  it "has a convenience method for UIApplication.sharedApplication.delegate" do
    @app.app_delegate.should == UIApplication.sharedApplication.delegate
    @screen.app_delegate.should == UIApplication.sharedApplication.delegate
    @tab_screen.app_delegate.should == UIApplication.sharedApplication.delegate
    @table_screen.app_delegate.should == UIApplication.sharedApplication.delegate
    @web_screen.app_delegate.should == UIApplication.sharedApplication.delegate
  end

  it "has a convenience method for UIApplication.sharedApplication.delegate.window" do
    @app.app_window.should == UIApplication.sharedApplication.delegate.window
    @screen.app_window.should == UIApplication.sharedApplication.delegate.window
    @tab_screen.app_window.should == UIApplication.sharedApplication.delegate.window
    @table_screen.app_window.should == UIApplication.sharedApplication.delegate.window
    @web_screen.app_window.should == UIApplication.sharedApplication.delegate.window
  end

  it "has a try method" do
    @app.try(:some_method).should == nil
    @screen.try(:some_method).should == nil
    @tab_screen.try(:some_method).should == nil
    @table_screen.try(:some_method).should == nil
    @web_screen.try(:some_method).should == nil
  end

end


