describe "split screen in tab bar functionality" do

  before do
    @app = TestDelegate.new

    @master_screen = HomeScreen.new nav_bar: true
    @detail_screen = BasicScreen.new nav_bar: true

    @split_screen = @app.create_split_screen @master_screen, @detail_screen, icon: "list", title: "Spec"
    @tab = @app.open_tab_bar @split_screen, HomeScreen, BasicScreen
  end

  after do
    @split_screen.delegate = nil # dereference to avoid memory issue
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

  it "should return screens for the master_screen and detail_screen methods" do
    @split_screen.master_screen.is_a?(PM::Screen).should == true
    @split_screen.detail_screen.is_a?(PM::Screen).should == true
  end

  it "should return navigationControllers" do
    @split_screen.viewControllers.first.is_a?(UINavigationController).should == true
    @split_screen.viewControllers.last.is_a?(UINavigationController).should == true
  end

  it "should set the first viewController to HomeScreen's main controller" do
    @split_screen.master_screen.should == @master_screen
    @split_screen.viewControllers.first.should == @master_screen.main_controller
  end

  it "should set the second viewController to BasicScreen's main controller" do
    @split_screen.detail_screen.should == @detail_screen
    @split_screen.viewControllers.last.should == @detail_screen.main_controller
  end

  it "should set the tab bar first viewController to the split screen" do
    @tab.viewControllers.first.should == @split_screen
  end
  
  it "should set the bar bar item for the split screen" do
    @split_screen.tabBarItem.is_a?(UITabBarItem).should == true
  end
  
  it "should set the tab bar icon of the split screen" do
    @split_screen.tabBarItem.image.is_a?(UIImage).should == true
  end
  
  it "should set the tab bar title of the split screen" do
    @split_screen.tabBarItem.title.is_a?(String).should == true
    @split_screen.tabBarItem.title.should == "Spec"
  end

end
