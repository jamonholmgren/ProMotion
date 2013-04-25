describe "screen properties" do

  before do

    # Simulate AppDelegate setup of main screen
    @screen = HomeScreen.new modal: true, nav_bar: true
    @screen.on_load

  end

  it "should store title" do
    HomeScreen.get_title.should == 'Home'
  end

  it "should let the instance reset the title" do
    @screen.title = "instance method"
    HomeScreen.get_title.should == 'instance method'
  end

  it "should store debug mode" do
    HomeScreen.debug_mode = true
    HomeScreen.debug_mode.should == true
  end

  it "#is_modal? should be true" do
    @screen.is_modal?.should == true
  end

  it "should know it is the first screen" do
    @screen.first_screen?.should == true
  end

  it "#should_autorotate should default to 'true'" do
    @screen.should_autorotate.should == true
  end


  describe "iOS lifecycle methods" do

    it "-viewDidLoad" do
      @screen.mock!(:view_did_load) { true }
      @screen.viewDidLoad.should == true
    end

    it "-viewWillAppear" do
      @screen.mock!(:view_will_appear) { |animated| animated.should == true }
      @screen.viewWillAppear(true)
    end

    it "-viewDidAppear" do
      @screen.mock!(:view_did_appear) { |animated| animated.should == true }
      @screen.viewDidAppear(true)
    end

    it "-viewWillDisappear" do
      @screen.mock!(:view_will_disappear) { |animated| animated.should == true }
      @screen.viewWillDisappear(true)
    end

    it "-viewDidDisappear" do
      @screen.mock!(:view_did_disappear) { |animated| animated.should == true }
      @screen.viewDidDisappear(true)
    end

    it "-shouldAutorotateToInterfaceOrientation" do
      @screen.mock!(:should_rotate) { |o| o.should == UIInterfaceOrientationPortrait }
      @screen.shouldAutorotateToInterfaceOrientation(UIInterfaceOrientationPortrait)
    end

    it "-shouldAutorotate" do
      @screen.mock!(:should_autorotate) { true }
      @screen.shouldAutorotate.should == true
    end

    it "-willRotateToInterfaceOrientation" do
      @screen.mock! :will_rotate do |orientation, duration| 
        orientation.should == UIInterfaceOrientationPortrait
        duration.should == 0.5
      end 
      @screen.willRotateToInterfaceOrientation(UIInterfaceOrientationPortrait, duration: 0.5)
    end

    it "-didRotateFromInterfaceOrientation" do
      @screen.mock!(:on_rotate) { true }
      @screen.didRotateFromInterfaceOrientation(UIInterfaceOrientationPortrait).should == true
    end

  end


  describe "navigation controller behavior" do

    it "should have a nav bar" do
      @screen.has_nav_bar?.should == true
    end

    it "#main_controller should return a navigation controller" do
      @screen.main_controller.should.be.instance_of ProMotion::NavigationController
    end

    it "have a right bar button item" do
      @screen.navigationItem.rightBarButtonItem.should.not == nil
    end

    it "should have a left bar button item" do
      @screen.navigationItem.leftBarButtonItem.should.not == nil
    end

  end

end
