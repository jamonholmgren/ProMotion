describe "ProMotion::Screen UIImage string title" do
  def controller
    @controller = ImageTitleScreen.new(nav_bar: true)
  end

  it "should allow an image title as a String" do
    controller.navigationItem.titleView.should.be.kind_of UIImageView
  end
end

describe "ProMotion::Screen UIImage title" do
  def controller
    @controller = UIImageTitleScreen.new(nav_bar: true)
  end

  it "should allow an image title as a UIImage" do
    controller.navigationItem.titleView.should.be.kind_of UIImageView
  end
end
