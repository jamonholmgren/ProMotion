describe "PM::Delegate" do
  before { @subject = TestDelegate.new }

  it 'should call on_load on launch' do
    @subject.mock!(:on_load) do |app, options|
      options[:jamon].should.be.true
      app.should.be.kind_of(UIApplication)
    end

    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions:{jamon: true})
  end

  it "should set home_screen when opening a new screen" do
    @subject.application(UIApplication.sharedApplication, willFinishLaunchingWithOptions: nil)
    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions: nil)
    screen = @subject.open BasicScreen.new(nav_bar: true)
    @subject.home_screen.should.be.kind_of BasicScreen
    @subject.window.rootViewController.should.be.kind_of UINavigationController
    screen.should.be.kind_of BasicScreen
  end

  it "should call will_load on launch" do
    @subject.called_will_load.should == nil
    @subject.application(UIApplication.sharedApplication, willFinishLaunchingWithOptions: nil)
    @subject.called_will_load.should == true
  end

  it "should call will_deactivate when quitting" do
    @subject.application(UIApplication.sharedApplication, willFinishLaunchingWithOptions: nil)
    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions: nil)
    @subject.called_will_deactivate.should == nil
    @subject.applicationWillResignActive(UIApplication.sharedApplication)
    @subject.called_will_deactivate.should == true
  end

  it "should call on_activate when resuming from an inactive state" do
    @subject.application(UIApplication.sharedApplication, willFinishLaunchingWithOptions: nil)
    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions: nil)
    @subject.applicationWillResignActive(UIApplication.sharedApplication)
    @subject.called_on_activate.should == nil
    @subject.applicationDidBecomeActive(UIApplication.sharedApplication)
    @subject.called_on_activate.should == true
  end

  it "should call on_enter_background when hitting the home button" do
    @subject.application(UIApplication.sharedApplication, willFinishLaunchingWithOptions: nil)
    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions: nil)
    @subject.called_on_enter_background.should == nil
    @subject.applicationDidEnterBackground(UIApplication.sharedApplication)
    @subject.called_on_enter_background.should == true
  end

  it "should call will_enter_foreground when hitting the home button" do
    @subject.application(UIApplication.sharedApplication, willFinishLaunchingWithOptions: nil)
    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions: nil)
    @subject.applicationDidEnterBackground(UIApplication.sharedApplication)
    @subject.called_will_enter_foreground.should == nil
    @subject.applicationWillEnterForeground(UIApplication.sharedApplication)
    @subject.called_will_enter_foreground.should == true
  end

  it "should call on_unload when the device is about to kill the app" do
    @subject.application(UIApplication.sharedApplication, willFinishLaunchingWithOptions: nil)
    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions: nil)
    @subject.called_on_unload.should == nil
    @subject.applicationWillTerminate(UIApplication.sharedApplication)
    @subject.called_on_unload.should == true
  end

  it "should handle open URL" do
    url = NSURL.URLWithString("http://example.com")
    sourceApplication = 'com.example'
    annotation = {jamon: true}
    @subject.mock!(:on_open_url) do |parameters|
      parameters[:url].should == url
      parameters[:source_app].should == sourceApplication
      parameters[:annotation][:jamon].should.be.true
    end

    @subject.application(UIApplication.sharedApplication, openURL: url, sourceApplication:sourceApplication, annotation: annotation)
  end

  describe "#on_continue_user_activity" do
    before do
      @subject.application(UIApplication.sharedApplication, continueUserActivity: {}, restorationHandler: [])
    end

    it "should call on_continue_user_activity when launching with a user activity" do
      @subject.called_on_continue_user_activity.should == true
    end

    it "should pass the user activity" do
      @subject.user_activity.should == {}
    end

    it "should pass the restoration_handler" do
      @subject.restoration_handler.should == []
    end
  end
end

# iOS 7 ONLY tests
if TestHelper.ios7
  describe "PM::Delegate Colors" do

    before do
      @subject = TestDelegateRed.new
      @screen = BasicScreen.new nav_bar: true
      @screen.view_will_appear(false)
      @subject.open @screen
    end

    it 'should set the application tint color on iOS 7' do
      @screen.view.tintColor.should == UIColor.redColor
    end

  end

end # End iOS 7 ONLY tests
