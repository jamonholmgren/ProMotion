describe "table screen refresh functionality" do

  # Note this test only works if on iOS 6+ or when using CKRefreshControl.

  before do
    @screen = TableScreenRefreshable.new
    @screen.on_load
  end

  it "should be refreshable" do
    @screen.class.get_refreshable.should == true
  end

  it "should create a refresh object" do
    @screen.instance_variable_get("@refresh_control").should.be.kind_of UIRefreshControl
  end

  it "should respond to start_refreshing and end_refreshing" do
    @screen.respond_to?(:start_refreshing).should == true
    @screen.respond_to?(:end_refreshing).should == true
  end

  # Animations cause the refresh object to fail when tested. Test manually.

end
