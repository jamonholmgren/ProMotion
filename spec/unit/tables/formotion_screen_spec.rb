describe "PM::FormotionScreen" do

  before do
    @screen = TestFormotionScreen.new
  end

  it "should store title" do
    TestFormotionScreen.get_title.should == 'Formotion Test'
    @screen.class.get_title.should == "Formotion Test"
  end

  it "should set default title on new instances" do
    @screen.title.should == "Formotion Test"
  end

  it "should fire the on_submit method when form is submitted" do
    @screen.form.submit
    @screen.submitted_form.should.not.be.nil
    @screen.submitted_form.render.should.be.kind_of(Hash)
  end

end
