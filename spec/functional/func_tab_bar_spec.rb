describe "PM::Tabs" do
  tests PM::Tabs

  # Override controller to properly instantiate
  def controller
    @app ||= TestDelegate.new
    
    @screen1 = BasicScreen.new(nav_bar: true, title: "Screen 1")
    @screen2 = BasicScreen.new(nav_bar: true, title: "Screen 2")
    @screen3 = BasicScreen.new(title: "Screen 3")
    @screen4 = BasicScreen.new(title: "Screen 4")
    
    @controller ||= @app.open_tab_bar(@screen1, @screen2, @screen3, @screen4)
    @tab_bar = @controller
  end

  it "should create a UITabBarController" do
    @app.window.rootViewController.should.be.kind_of UITabBarController
  end
  
  it "should have four tabs" do
    @tab_bar.viewControllers.length.should == 4
  end
  
  it "should have the right screens in the right places" do
    @tab_bar.viewControllers[0].should == @screen1.navigationController
    @tab_bar.viewControllers[1].should == @screen2.navigationController
    @tab_bar.viewControllers[2].should == @screen3
    @tab_bar.viewControllers[3].should == @screen4
  end
  
  it "should allow opening a tab by the name from any screen" do
    @screen1.open_tab "Screen 2"
    @tab_bar.selectedIndex.should == 1
    @screen2.open_tab "Screen 3"
    @tab_bar.selectedIndex.should == 2
    @screen3.open_tab "Screen 4"
    @tab_bar.selectedIndex.should == 3
    @screen4.open_tab "Screen 1"
    @tab_bar.selectedIndex.should == 0
  end

  it "should allow opening a tab by the index from any screen" do
    @screen1.open_tab 1
    @tab_bar.selectedIndex.should == 1
    @screen2.open_tab 2
    @tab_bar.selectedIndex.should == 2
    @screen3.open_tab 3
    @tab_bar.selectedIndex.should == 3
    @screen4.open_tab 0
    @tab_bar.selectedIndex.should == 0
  end
  
  it "should allow opening a tab from the app_delegate" do
    @app.open_tab "Screen 2"
    @tab_bar.selectedIndex.should == 1
    @app.open_tab "Screen 3"
    @tab_bar.selectedIndex.should == 2
    @app.open_tab "Screen 4"
    @tab_bar.selectedIndex.should == 3
    @app.open_tab "Screen 1"
    @tab_bar.selectedIndex.should == 0
  end
  
  it "should allow opening a tab by accessing the tab bar directly" do
    @tab_bar.open_tab "Screen 2"
    @tab_bar.selectedIndex.should == 1
    @tab_bar.open_tab "Screen 3"
    @tab_bar.selectedIndex.should == 2
    @tab_bar.open_tab "Screen 4"
    @tab_bar.selectedIndex.should == 3
    @tab_bar.open_tab "Screen 1"
    @tab_bar.selectedIndex.should == 0
  end
  
  

end
