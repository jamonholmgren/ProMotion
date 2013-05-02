describe "split screen functionality" do

  before do
    @app = TestDelegate.new
    
    @master_screen = HomeScreen.new nav_bar: true
    @detail_screen = BasicScreen.new # no nav_bar on this one
    
    @split_screen = @app.open_split_screen @master_screen, @detail_screen
  end
  
  it "should have created a split screen" do
    @split_screen.should != nil
    @split_screen.is_a?(UISplitViewController).should == true
  end
  
  it "should have two viewControllers" do
    @split_screen.viewControllers.length.should == 2
  end
  
  it "should set the root view to the UISplitScreenViewController" do
    @app.window.rootViewController.should == @split_screen
  end
  
  it "should set the first viewController to HomeScreen" do
    @split_screen.master_screen.should == @master_screen
    @split_screen.viewControllers.first.should == @master_screen.main_controller
  end
  
  it "should set the second viewController to BasicScreen" do
    @split_screen.detail_screen.should == @detail_screen
    @split_screen.viewControllers.last.should == @detail_screen.main_controller
  end
  
end