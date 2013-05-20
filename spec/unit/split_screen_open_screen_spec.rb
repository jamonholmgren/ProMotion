describe "split screen `open` functionality" do

  before do
    @app = TestDelegate.new

    @master_screen = HomeScreen.new nav_bar: true
    @detail_screen_1 = BasicScreen.new # no nav_bar on this one
    @detail_screen_2 = BasicScreen.new(nav_bar: true)

    @split_screen = @app.open_split_screen @master_screen, @detail_screen_1
  end

  after do
    @split_screen.delegate = nil # dereference to avoid memory issue
  end

  it "should open a new screen in the detail view" do
    @master_screen.open @detail_screen_2, in_detail: true
    @split_screen.detail_screen.should == @detail_screen_2
    @split_screen.viewControllers.first.should == @master_screen.main_controller
    @split_screen.viewControllers.last.should == @detail_screen_2.main_controller
  end

  it "should open a new screen in the master view" do
    @detail_screen_1.open @detail_screen_2, in_master: true
    @split_screen.master_screen.should == @detail_screen_2
    @split_screen.viewControllers.first.should == @detail_screen_2.main_controller
    @split_screen.viewControllers.last.should == @detail_screen_1.main_controller
  end

  it "should open a new screen in the master view's navigation controller" do
    @master_screen.open @detail_screen_2
    @split_screen.detail_screen.should == @detail_screen_1 # no change
    @master_screen.navigationController.topViewController.should == @detail_screen_2
  end

  it "should open a new modal screen in the detail view" do
    @detail_screen_1.open @detail_screen_2, modal: true
    @split_screen.detail_screen.should == @detail_screen_1
    @detail_screen_1.presentedViewController.should == @detail_screen_2.main_controller
  end

  it "should not interfere with normal non-split screen navigation" do
    home = HomeScreen.new(nav_bar: true)
    child = BasicScreen.new
    home.open child, in_detail: true, in_master: true
    home.navigation_controller.topViewController.should == child
  end

end
