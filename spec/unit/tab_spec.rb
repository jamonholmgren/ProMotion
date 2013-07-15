describe "tab bar functionality" do

  before do
    @app = TestDelegate.new

    @tab_1 = TabScreen.new
    @tab_2 = BasicScreen.new
    @tab_3 = HomeScreen.new
    @tab_4 = TestTableScreen.new

    @tab_bar = @app.open_tab_bar @tab_1, @tab_2, @tab_3, @tab_4
  end

  after do
    
  end

  it "should have created a tab bar with four items" do
    @tab_bar.should != nil
    @tab_bar.should.be.kind_of(UITabBarController)
    @tab_bar.viewControllers.length.should == 4
  end
  
  it "should have set a custom tab bar item" do
    @tab_bar.tabBar.items.first.title.should == "Tab Item"
  end
  
  it "should have set the others to their respective titles" do
    @tab_bar.tabBar.items[1].title.should == "Basic"
    @tab_bar.tabBar.items[2].title.should == "Home"
    @tab_bar.tabBar.items[3].title.should == "TestTableScreen"
  end
  
  it "should allow changing the tab bar item with set_tab_bar_item" do
    @tab_1.set_tab_bar_item title: "Custom", icon: "test.jpeg"
    @tab_bar.tabBar.items.first.title.should == "Custom"
  end

end


