describe "ProMotion::Screen UIImageView title" do
  def controller
    @controller = ImageViewTitleScreen.new(nav_bar: true)
  end

  it "should allow an image title" do
    controller.navigationItem.titleView.should.be.kind_of UIImageView
  end
end
