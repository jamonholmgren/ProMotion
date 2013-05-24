describe "PM::NotificationHelper" do
  before do
    @app = TestDelegate.new
    @subject = NotificationCenterScreen.new
 end

  it 'should have active observers' do
    @subject.active_observers.count.should == 1
    @subject.has_changed?.should == false
    notification_screen = NotificationModalScreen.new
    @app.open notification_screen, modal: true
    notification_screen.dismiss_with_notification
    @subject.has_changed?.should == true
  end

end

