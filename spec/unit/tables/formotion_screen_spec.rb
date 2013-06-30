describe "PM::FormotionScreen" do

  before do
    @screen = TestFormotionScreen.new
  end

  it "should store title" do
    TestFormotionScreen.get_title.should == 'Formotion Test'
  end

  it "should set default title on new instances" do
    @screen.title.should == "Formotion Test"
  end

end
