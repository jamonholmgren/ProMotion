describe "Application 'basic_app'" do
  before do
    @app = UIApplication.sharedApplication
  end

  it "has one window" do
    @app.windows.size.should == 1
  end

  it "is a ProMotion app" do
    @app.delegate.should.be.kind_of(PM::Delegate)
  end
end
