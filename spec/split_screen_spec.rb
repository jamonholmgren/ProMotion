describe "split screen functionality" do

  before do
    @app = TestDelegate.new
    
    @master_screen = HomeScreen.new nav_bar: true
    @child_screen = BasicScreen.new nav_bar: true
    
    @split_screen = @app.open_split_screen @master_screen, @child_screen
  end
  
  it "should have two viewControllers" do
    @split_screen.viewControllers.length.should == 2
  end
  
  it "should set the root view to the UISplitScreenViewController" do
    @app.window.rootViewController.should == @split_screen
  end
  
  it "should set the first viewController to HomeScreen" do
    @split_screen.viewControllers.first.should == @master_screen
  end
  
  it "should set the second viewController to BasicScreen" do
    @split_screen.viewControllers.last.should == @child_screen
  end
  
end