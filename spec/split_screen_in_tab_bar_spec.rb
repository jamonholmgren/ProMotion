describe "split screen in tab bar functionality" do

  before do
    @app = TestDelegate.new
    
    @master_screen = HomeScreen.new nav_bar: true
    @child_screen = BasicScreen.new nav_bar: true
    
    @split_screen = @app.create_split_screen @master_screen, @child_screen
    @tab = @app.open_tab_bar @split_screen, HomeScreen, BasicScreen
  end
  
  it "should create a UISplitViewController" do
    @split_screen.is_a?(UISplitViewController).should == true
  end
  
  it "should have two viewControllers" do
    @split_screen.viewControllers.length.should == 2
  end
  
  it "should set the root view to the tab bar" do
    @app.window.rootViewController.should == @tab
  end
  
  it "should set the first viewController to HomeScreen" do
    @split_screen.viewControllers.first.should == @master_screen
  end
  
  it "should set the second viewController to BasicScreen" do
    @split_screen.viewControllers.last.should == @child_screen
  end
  
  it "should set the tab bar first viewController to the split screen" do 
    @tab.viewControllers.first.should == @split_screen
  end
  
end