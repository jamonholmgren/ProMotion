describe "PM::ScreenModule" do

  before { @subject = ScreenModuleViewController.new }

  it 'should have PM::ScreenModule in ancestors' do
    @subject.class.ancestors.include?(PM::ScreenModule).should == true
  end

  it 'should have a title from class method #title' do
    @subject.title.should == 'Test Title'
  end

  it 'should allow a NSAttributedString' do
    @subject.title = NSAttributedString.alloc.initWithString("Test Title")
    @subject.title.string.should == "Test Title"
  end

end
