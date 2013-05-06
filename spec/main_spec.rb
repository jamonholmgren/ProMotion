describe "pro motion module" do

  it "should have 'PM' module" do
    should.not.raise(NameError) { PM }
  end

  it "should not allow screen inclusion into just any class" do
    dummy = DummyClass.new
    dummy.extend ProMotion::ScreenModule
    should.raise(StandardError) { dummy.on_create }
  end

end
