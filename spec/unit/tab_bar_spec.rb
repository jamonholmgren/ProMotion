describe "PM::Tabs" do
  def app
    @app ||= TestDelegate.new
  end

  def tab_bar
    @tab_bar ||= begin
      @screen1 = BasicScreen.new(nav_bar: true, title: "Screen 1")
      @screen2 = BasicScreen.new(nav_bar: true, title: "Screen 2")
      @screen3 = BasicScreen.new(title: "Screen 3")
      @screen4 = BasicScreen.new(title: "Screen 4")

      app.open_tab_bar(@screen1, @screen2, @screen3, @screen4)
    end
  end

  it "should create a UITabBarController" do
    tab_bar
    app.window.rootViewController.should.be.kind_of UITabBarController
  end

  it "should set the the pm_tab_delegate to the opener" do
    tab_bar.pm_tab_delegate.should.equal(app)
    tab_bar.delegate.should.equal(tab_bar)
  end

  it "should call should_select_tab before a tab is selected" do
    tab_bar.pm_tab_delegate.called_should_select_tab = false
    @screen1.open_tab "Screen 2"
    tab_bar.pm_tab_delegate.called_should_select_tab.should.be.true
  end

  it "should call on_tab_selected when a tab is selected" do
    tab_bar.pm_tab_delegate.called_on_tab_selected = false
    @screen1.open_tab "Screen 2"
    tab_bar.pm_tab_delegate.called_on_tab_selected.should.be.true
  end

  it "should call on_tab_selected when delegate does not respond to should_select_tab" do
    method_to_stub = :can_send_method_to_delegate?
    tab_bar.pm_tab_delegate.stub!(method_to_stub) do |method|
      method == :should_select_tab ? false : send("__original_#{method_to_stub}", method)
    end

    tab_bar.pm_tab_delegate.called_on_tab_selected = false
    @screen1.open_tab "Screen 2"
    tab_bar.pm_tab_delegate.called_on_tab_selected.should.be.true

    tab_bar.pm_tab_delegate.reset(method_to_stub)
  end

  it "does not call on_tab_selected when should_select_tab returns false" do
    method_to_stub = :should_select_tab
    tab_bar.pm_tab_delegate.stub!(method_to_stub) { |_vc| false }

    tab_bar.pm_tab_delegate.called_on_tab_selected = false
    @screen1.open_tab "Screen 2"
    tab_bar.pm_tab_delegate.called_on_tab_selected.should.be.false

    tab_bar.pm_tab_delegate.reset(method_to_stub)
  end

  it "should have four tabs" do
    tab_bar.viewControllers.length.should == 4
  end

  it "should have correct tags on each tabBarItem" do
    @screen1.tabBarItem.tag.should == 0
    @screen2.tabBarItem.tag.should == 1
    @screen3.tabBarItem.tag.should == 2
    @screen4.tabBarItem.tag.should == 3
  end

  it "should have the right screens in the right places" do
    tab_bar.viewControllers[0].should == @screen1.navigationController
    tab_bar.viewControllers[1].should == @screen2.navigationController
    tab_bar.viewControllers[2].should == @screen3
    tab_bar.viewControllers[3].should == @screen4
  end

  it "should allow opening a tab by the name from any screen" do
    @screen1.open_tab "Screen 2"
    tab_bar.selectedIndex.should == 1
    @screen2.open_tab "Screen 3"
    tab_bar.selectedIndex.should == 2
    @screen3.open_tab "Screen 4"
    tab_bar.selectedIndex.should == 3
    @screen4.open_tab "Screen 1"
    tab_bar.selectedIndex.should == 0
  end

  it "should allow opening a tab by the index from any screen" do
    @screen1.open_tab 1
    tab_bar.selectedIndex.should == 1
    @screen2.open_tab 2
    tab_bar.selectedIndex.should == 2
    @screen3.open_tab 3
    tab_bar.selectedIndex.should == 3
    @screen4.open_tab 0
    tab_bar.selectedIndex.should == 0
  end

  it "should allow opening a tab from the app_delegate" do
    app.open_tab "Screen 2"
    tab_bar.selectedIndex.should == 1
    app.open_tab "Screen 3"
    tab_bar.selectedIndex.should == 2
    app.open_tab "Screen 4"
    tab_bar.selectedIndex.should == 3
    app.open_tab "Screen 1"
    tab_bar.selectedIndex.should == 0
  end

  it "should allow opening a tab by accessing the tab bar directly" do
    tab_bar.open_tab "Screen 2"
    tab_bar.selectedIndex.should == 1
    tab_bar.open_tab "Screen 3"
    tab_bar.selectedIndex.should == 2
    tab_bar.open_tab "Screen 4"
    tab_bar.selectedIndex.should == 3
    tab_bar.open_tab "Screen 1"
    tab_bar.selectedIndex.should == 0
  end

  it "should recognize setting #should_autorotate in screen" do
    @screen1.stub! :should_autorotate, return: false
    @tab_bar.shouldAutorotate.should == false
  end

end
