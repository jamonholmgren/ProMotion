describe "tab bar functionality" do

  before do
    @app = TestDelegate.new

    @tab_0 = TabScreen.new
    @tab_1 = BasicScreen.new
    @tab_2 = HomeScreen.new
    @tab_3 = TestTableScreen.new

    @tab_bar = @app.open_tab_bar @tab_0, @tab_1, @tab_2, @tab_3
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

  it "should allow setting image insets" do
    @tab_bar.tabBar.items.first.imageInsets.should == UIEdgeInsetsMake(5,5,5,5)
  end

  it "should have set the others to their respective titles" do
    @tab_bar.tabBar.items[1].title.should == "Basic"
    @tab_bar.tabBar.items[2].title.should == "Home"
    @tab_bar.tabBar.items[3].title.should == "Test tab title"
  end

  it "should allow changing the tab bar item with set_tab_bar_item" do
    @tab_0.set_tab_bar_item title: "Custom", item: "test.jpeg"
    @tab_bar.tabBar.items.first.title.should == "Custom"
  end

  it "should allow replacing a view controller with `open`" do
    new_screen = BasicScreen.new
    @tab_3.open new_screen, in_tab: "Home"
    @tab_bar.viewControllers[2].should == new_screen
  end

  describe "changing tab bar orders" do
    before do
      # Reset the user defaults
      app_domain = NSBundle.mainBundle.bundleIdentifier
      NSUserDefaults.standardUserDefaults.removePersistentDomainForName(app_domain)
      NSUserDefaults.standardUserDefaults.synchronize

      @tab_0 = TabScreen.new
      @tab_1 = BasicScreen.new
      @tab_2 = HomeScreen.new
      @tab_3 = TestTableScreen.new
      @tab_4 = PresentScreen.new
      @tab_5 = TestWebScreen.new

      @tab_bar = @app.open_tab_bar @tab_0, @tab_1, @tab_2, @tab_3, @tab_4, @tab_5
    end

    it "should start without a name" do
      @tab_bar.name.should.be.nil
    end

    it "should set a name" do
      NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_test_tabs").should.be.nil
      @tab_bar.name = "test_tabs"
      @tab_bar.name.should == "test_tabs"
    end

    it "should not save the order when not changed" do
      NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_").should.be.nil
      @tab_bar.tabBarController(@tab_bar, didEndCustomizingViewControllers:@tab_bar.viewControllers, changed:false)
      NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_").should.be.nil
    end

    it "should save an order without a name" do
      @tab_bar.name = ""
      new_order = [@tab_5, @tab_1, @tab_2, @tab_3, @tab_4, @tab_0]
      NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_").should.be.nil
      @tab_bar.tabBarController(@tab_bar, didEndCustomizingViewControllers:new_order, changed:true)
      NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_").nil?.should == false
      NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_").should == [5, 1, 2, 3, 4, 0]
    end

    it "should save an order with a name" do
      new_name = "test_tab_bar"

      @tab_bar.name = new_name
      new_order = [@tab_5, @tab_4, @tab_3, @tab_2, @tab_1, @tab_0]
      NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_#{new_name}").should.be.nil
      @tab_bar.tabBarController(@tab_bar, didEndCustomizingViewControllers:new_order, changed:true)
      NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_#{new_name}").should == [5, 4, 3, 2, 1, 0]
    end

    it "should persist order when reopening the tabs" do
      @tab_bar.name = "test_tab_bar"
      new_order = [@tab_5, @tab_4, @tab_3, @tab_2, @tab_1, @tab_0]
      @tab_bar.tabBarController(@tab_bar, didEndCustomizingViewControllers:new_order, changed:true)

      new_tab_bar = @app.open_tab_bar @tab_0, @tab_1, @tab_2, @tab_3, @tab_4, @tab_5
      new_tab_bar.name = "test_tab_bar"
      new_tab_bar.viewControllers.should == new_order
    end

    it "should always select the leftmost tab when rearranging tabs" do
      new_order = [@tab_5, @tab_4, @tab_3, @tab_2, @tab_1, @tab_0]
      @tab_bar.tabBarController(@tab_bar, didEndCustomizingViewControllers:new_order, changed:true)
      new_tab_bar = @app.open_tab_bar @tab_0, @tab_1, @tab_2, @tab_3, @tab_4, @tab_5
      new_tab_bar.selectedIndex.should == 0
    end

  end

end
