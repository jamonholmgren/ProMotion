describe "screen properties" do

  before do
    # Simulate AppDelegate setup of main screen
    @screen = HomeScreen.new modal: true, nav_bar: true
    @screen.on_load
  end

  it "does not have a default title" do
    screen = UntitledScreen.new
    screen.title.should == nil
  end

  it "does not display a default title in the nav bar" do
    screen = UntitledScreen.new
    screen.navigationItem.title.should == nil
  end

  it "should store title" do
    HomeScreen.title.should == "Home"
  end

  it "should set default title on new instances" do
    @screen.title.should == "Home"
  end

  it "should let the instance set its title" do
    @screen.title = "instance method"
    @screen.title.should == 'instance method'
  end

  it "should not let the instance reset the default title" do
    @screen.title = "instance method"
    HomeScreen.title.should != 'instance method'
  end

  it "should set the UIStatusBar style to :none" do
    @screen.class.status_bar :none
    @screen.view_will_appear(false)
    UIApplication.sharedApplication.isStatusBarHidden.should == true
  end

  it "should set the UIStatusBar style to :light" do
    @screen.class.status_bar :light
    @screen.view_will_appear(false)
    UIApplication.sharedApplication.isStatusBarHidden.should == false
    UIApplication.sharedApplication.statusBarStyle.should == UIStatusBarStyleLightContent
  end

  it "should set the UIStatusBar style to :dark" do
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent
    @screen.class.status_bar :dark
    @screen.view_will_appear(false)
    UIApplication.sharedApplication.isStatusBarHidden.should == false
    UIApplication.sharedApplication.statusBarStyle.should == UIStatusBarStyleDefault
  end

  it "should default to a global UIStatusBar style" do
    NSBundle.mainBundle.mock!(:objectForInfoDictionaryKey) do |key|
      "UIStatusBarStyleLightContent"
    end
    @screen.class.status_bar :default
    @screen.view_will_appear(false)
    UIApplication.sharedApplication.isStatusBarHidden.should == false
    UIApplication.sharedApplication.statusBarStyle.should == UIStatusBarStyleLightContent
  end

  it "should default to a hidden UIStatusBar if already hidden" do
    UIApplication.sharedApplication.setStatusBarHidden(true, withAnimation: UIStatusBarAnimationNone)
    @screen.class.status_bar :default
    @screen.view_will_appear(false)
    UIApplication.sharedApplication.isStatusBarHidden.should == true
  end

  it "should set the tab bar item with a system item" do
    @screen.set_tab_bar_item system_item: :contacts
    comparison = UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemContacts, tag: 0)
    @screen.tabBarItem.systemItem.should == comparison.systemItem
    @screen.tabBarItem.tag.should == comparison.tag
    @screen.tabBarItem.image.should == comparison.image
  end

  it "should set the tab bar item with a custom item and title" do
    @screen.set_tab_bar_item title: "My Screen", item: "list"

    item_image = UIImage.imageNamed("list")
    comparison = UITabBarItem.alloc.initWithTitle("My Screen", image: item_image, tag: 0)

    @screen.tabBarItem.systemItem.should == comparison.systemItem
    @screen.tabBarItem.tag.should == comparison.tag
    @screen.tabBarItem.image.should == comparison.image
  end

  it "#modal? should be true" do
    @screen.modal?.should == true
  end

  it "should know it is the first screen" do
    @screen.first_screen?.should == true
  end

  it "#should_autorotate should default to 'true'" do
    @screen.should_autorotate.should == true
  end

  it "should allow opening and closing a modal screen" do
    parent_screen = BasicScreen.new(nav_bar: true)
    parent_screen.mock!(:"presentViewController:animated:completion:") do |controller, animated, completion|
      controller.should == @screen.navigationController
    end
    parent_screen.open_modal @screen
    parent_screen.mock!(:"dismissViewControllerAnimated:completion:") do |animated, completion|
      animated.should == true
    end
    @screen.close
  end

  it "should push another screen with animation by default" do
    parent_screen = BasicScreen.new(nav_bar: true)
    parent_screen.navigationController.mock!(:"pushViewController:animated:") do |controller, animated|
      animated.should == true
    end
    parent_screen.open @screen
  end

  it "should push another screen with animation when animated: true" do
    parent_screen = BasicScreen.new(nav_bar: true)
    parent_screen.navigationController.mock!(:"pushViewController:animated:") do |controller, animated|
      animated.should == true
    end
    parent_screen.open @screen, animated: true
  end

  it "should push another screen without animation when animated: false" do
    parent_screen = BasicScreen.new(nav_bar: true)
    parent_screen.navigationController.mock!(:"pushViewController:animated:") do |controller, animated|
      animated.should == false
    end
    parent_screen.open @screen, animated: false
  end

  # Issue https://github.com/clearsightstudio/ProMotion/issues/109
  it "#should_autorotate should fire when shouldAutorotate fires when in a navigation bar" do
    parent_screen = BasicScreen.new(nav_bar: true)
    parent_screen.open @screen, animated: false
    @screen.mock!(:should_autorotate) { true.should == true }
    parent_screen.navigationController.shouldAutorotate
  end

  it "#should_autorotate shouldn't crash when NavigationController's visibleViewController is nil" do
    parent_screen = BasicScreen.new(nav_bar: true)
    parent_screen.open @screen, animated: false
    @screen.navigationController.mock!(:visibleViewController) { nil }
    parent_screen.navigationController.shouldAutorotate
  end

  # <= iOS 5 only
  it "#should_rotate(orientation) should fire when shouldAutorotateToInterfaceOrientation(orientation) fires" do
    @screen.mock!(:should_rotate) { |orientation| orientation.should == UIInterfaceOrientationMaskPortrait }
    @screen.shouldAutorotateToInterfaceOrientation(UIInterfaceOrientationMaskPortrait)
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

  describe "memory warnings" do

    it "should call didReceiveMemoryWarning when exists" do
      memory_screen = MemoryWarningScreenSelfImplemented.new
      memory_screen.memory_warning_from_uikit.should.be.nil
      memory_screen.didReceiveMemoryWarning
      memory_screen.memory_warning_from_uikit.should == true
    end

    it "should call super up the chain" do
      memory_screen = MemoryWarningNotSoSuperScreen.new

      memory_screen.memory_warning_from_super.should.be.nil
      memory_screen.didReceiveMemoryWarning
      memory_screen.memory_warning_from_super.should == true
    end

    it "should call on_memory_warning when implemented" do
      memory_screen = MemoryWarningScreen.new

      memory_screen.memory_warning_from_pm.should.be.nil
      memory_screen.didReceiveMemoryWarning
      memory_screen.memory_warning_from_pm.should == true
    end

  end

  describe "navigation controller behavior" do

    it "should have a navigation bar" do
      @screen.navigationController.should.be.kind_of UINavigationController
    end

    it "should let the instance set the nav_controller" do
      screen = HomeScreen.new nav_bar: true, nav_controller: CustomNavigationController
      screen.on_load
      screen.navigationController.should.be.instance_of CustomNavigationController
    end

    it "#navigationController should return a navigation controller" do
      @screen.navigationController.should.be.instance_of ProMotion::NavigationController
    end

    it "should have a nav bar" do
      @screen.nav_bar?.should == true
    end

    it "have a right bar button item" do
      @screen.navigationItem.rightBarButtonItem.should.not == nil
    end

    it "should have a left bar button item" do
      @screen.navigationItem.leftBarButtonItem.should.not == nil
    end

    it "should set the given action on a left bar button item" do
      @screen.navigationItem.leftBarButtonItem.action.should == :save_something
    end

    it "should set the given action on a right bar button item" do
      @screen.navigationItem.rightBarButtonItem.action.should == :return_to_some_other_screen
    end
  end

  describe "bar button behavior" do
    describe "system bar buttons" do
      before do
        @screen.set_nav_bar_button :right, title: nil, action: :add_something, system_item: UIBarButtonSystemItemAdd
      end

      it "has a right bar button item of the correct type" do
        @screen.navigationItem.rightBarButtonItem.should.be.instance_of UIBarButtonItem
      end

      it "is an add button" do
        @screen.navigationItem.rightBarButtonItem.action.should == :add_something
      end
    end

    describe "bar button tint colors" do
      before do
        @screen.set_nav_bar_button :right, title: nil, action: :add_something, system_item: UIBarButtonSystemItemAdd, tint_color: UIColor.blueColor
      end

      it "sets the tint color" do
        CGColorEqualToColor(@screen.navigationItem.rightBarButtonItem.tintColor, UIColor.blueColor).should == true
      end
    end

    describe 'titled bar buttons' do
      before do
        @screen.set_nav_bar_button :right, title: "Save", action: :save_something, style: UIBarButtonItemStyleDone
      end

      it "has a right bar button item of the correct type" do
        @screen.navigationItem.rightBarButtonItem.should.be.instance_of UIBarButtonItem
      end

      it "has a right bar button item of the correct style" do
        @screen.navigationItem.rightBarButtonItem.style.should == UIBarButtonItemStyleDone
      end

      it "is titled correctly" do
        @screen.navigationItem.rightBarButtonItem.title.should == 'Save'
      end
    end

    describe 'image bar buttons' do
      before do
        @image = UIImage.alloc.init
        @screen.set_nav_bar_button :right, title: @image, action: :save_something, style: UIBarButtonItemStyleDone
      end

      it "has a right bar button item of the correct type" do
        @screen.navigationItem.rightBarButtonItem.should.be.instance_of UIBarButtonItem
      end

      it "is has the right image" do
        @screen.navigationItem.rightBarButtonItem.title.should == nil
      end
    end

    describe 'custom view bar buttons' do
      before do
        @activity = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite)
        @screen.set_nav_bar_button :right, {custom_view: @activity}
      end

      it "has a right bar button item of the correct type" do
        @screen.navigationItem.rightBarButtonItem.should.be.instance_of UIBarButtonItem
        @screen.navigationItem.rightBarButtonItem.customView.should.be.instance_of UIActivityIndicatorView
      end
    end

  end

end

describe "screen with toolbar" do

  it "showing" do
    # Simulate AppDelegate setup of main screen
    screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: true)
    screen.on_load
    screen.navigationController.toolbarHidden?.should == false
  end

  it "hidden" do
    screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: false)
    screen.on_load
    screen.navigationController.toolbarHidden?.should == true
  end

  it "adds a single item" do
    screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: true)
    screen.on_load
    screen.set_toolbar_button([{title: "Testing Toolbar"}])

    screen.navigationController.toolbar.items.should.be.instance_of Array
    screen.navigationController.toolbar.items.count.should == 1
    screen.navigationController.toolbar.items.first.should.be.instance_of UIBarButtonItem
    screen.navigationController.toolbar.items.first.title.should == "Testing Toolbar"
  end

  it "adds multiple items" do
    screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: true)
    screen.set_toolbar_buttons [{title: "Testing Toolbar"}, {title: "Another Test"}]

    screen.navigationController.toolbar.items.should.be.instance_of Array
    screen.navigationController.toolbar.items.count.should == 2
    screen.navigationController.toolbar.items.first.title.should == "Testing Toolbar"
    screen.navigationController.toolbar.items.last.title.should == "Another Test"
  end

  it "shows the toolbar when setting items" do
    screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: false)
    screen.on_load
    screen.navigationController.toolbarHidden?.should == true
    screen.set_toolbar_button([{title: "Testing Toolbar"}], false)
    screen.navigationController.toolbarHidden?.should == false
  end

  it "doesn't show the toolbar when passed nil" do
    screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: true)
    screen.on_load
    screen.set_toolbar_button(nil, false)
    screen.navigationController.toolbarHidden?.should == true
  end

  it "doesn't show the toolbar when passed false" do
    screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: true)
    screen.on_load
    screen.set_toolbar_button(false, false)
    screen.navigationController.toolbarHidden?.should == true
  end

  it "hides the toolbar when passed nil" do
    screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: true)
    screen.on_load
    screen.set_toolbar_button([{title: "Testing Toolbar"}], false)
    screen.navigationController.toolbarHidden?.should == false
    screen.set_toolbar_button(nil, false)
    screen.navigationController.toolbarHidden?.should == true
  end

end

describe "toolbar tinted buttons" do
  before do
    @screen = HomeScreen.new(nav_bar: true, modal: true, toolbar: true)
    @screen.on_load
  end

  it "creates string toolbar buttons with tint colors" do
    @screen.set_toolbar_button([{title: "Testing Toolbar", tint_color: UIColor.redColor}])
    @screen.navigationController.toolbar.items.first.tintColor.should == UIColor.redColor
  end

  it "creates image toolbar buttons with tint colors" do
    @screen.set_toolbar_button([{image: UIImage.imageNamed("list"), tint_color: UIColor.redColor}])
    @screen.navigationController.toolbar.items.first.tintColor.should == UIColor.redColor
  end

  it "creates system item toolbar buttons with tint colors" do
    @screen.set_toolbar_button([{system_item: :reply, tint_color: UIColor.redColor}])
    @screen.navigationController.toolbar.items.first.tintColor.should == UIColor.redColor
  end

end

describe "child screen management" do
  before do
    @screen = HomeScreen.new
    @child = BasicScreen.new
  end

  it "#add_child_screen" do
    autorelease_pool do
      @screen.add_child_screen @child
    end
    @screen.childViewControllers.should.include(@child)
    @screen.childViewControllers.length.should == 1
    @child.parent_screen.should == @screen
  end

  it "#remove_child_screen" do
    @screen.add_child_screen @child
    @screen.childViewControllers.should.include(@child)
    @screen.remove_child_screen @child
    @screen.childViewControllers.length.should == 0
    @child.parent_screen.should == nil
  end

end


