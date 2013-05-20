describe "split screen functionality" do

  before do
    @app = TestDelegate.new

    @master_screen = MasterScreen.new nav_bar: true
    @detail_screen = DetailScreen.new # no nav_bar on this one

    @split_screen = @app.open_split_screen @master_screen, @detail_screen
  end

  after do
    @split_screen.delegate = nil # dereference to avoid memory issue
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

  it "should set the first viewController to MasterScreen" do
    @split_screen.master_screen.should == @master_screen
    @split_screen.viewControllers.first.should == @master_screen.main_controller
  end

  it "should set the second viewController to DetailScreen" do
    @split_screen.detail_screen.should == @detail_screen
    @split_screen.viewControllers.last.should == @detail_screen.main_controller
  end

  it "should set the title on both screens" do
    @master_screen.class.send(:get_title).should == "Master"
    @master_screen.title.should == "Master"
    @detail_screen.class.send(:get_title).should == "Detail"
    @detail_screen.title.should == "Detail"
  end
end

# Regression test for https://github.com/clearsightstudio/ProMotion/issues/74
describe "split screen with UIViewControllers with ScreenModule" do

  before do
    @app = TestDelegate.new

    @master_screen = ScreenModuleViewController.new
    @detail_screen = DetailScreen.new(nav_bar: true)

    @split_screen = @app.open_split_screen @master_screen, @detail_screen
  end

  it "should set the title on both screens" do
    @master_screen.class.send(:get_title).should == "Test Title"
    @master_screen.title.should == "Test Title"
    @detail_screen.class.send(:get_title).should == "Detail"
    @detail_screen.title.should == "Detail"
  end

end

