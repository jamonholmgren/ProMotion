describe "PM::Delegate" do

  before { @subject = TestDelegate.new }

  it 'should call on_load on launch' do
    @subject.mock!(:on_load) do |app, options|
      options[:jamon].should.be.true
      app.should.be.kind_of(UIApplication)
    end

    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions:{jamon: true})
  end

  it "should handle push notifications" do

    @subject.mock!(:on_push_notification) do |notification|
      notification.should.be.kind_of(PM::PushNotification)
      notification.alert.should == "Eating Bacon"
      notification.badge.should == 42
      notification.sound.should == "jamon"
      @subject.aps_notification.should == notification
    end

    launch_options = { UIApplicationLaunchOptionsRemoteNotificationKey => PM::PushNotification.fake_notification(alert: "Eating Bacon", badge: 42, sound: "jamon").notification }
    @subject.application(nil, didFinishLaunchingWithOptions:launch_options )

  end

  it "should set home_screen when opening a new screen" do

    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions: nil)
    screen = @subject.open BasicScreen.new(nav_bar: true)
    @subject.home_screen.should.be.kind_of BasicScreen
    @subject.window.rootViewController.should.be.kind_of UINavigationController
    screen.should.be.kind_of BasicScreen

  end

end
