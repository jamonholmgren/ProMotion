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

  describe "After update_table_data" do
    before do
      @screen.test_update_table_data
    end

    it "should update the table data" do
      @screen.table_data[:sections][0][:title].should == "Updated Data"
    end

    it "should fire the on_submit method when form is submitted" do
      @screen.form.submit
      @screen.submitted_form.should.not.be.nil
      @screen.submitted_form.render.should.be.kind_of(Hash)
    end
  end
end