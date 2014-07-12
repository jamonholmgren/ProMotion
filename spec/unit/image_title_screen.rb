describe "ProMotion::Screen UIImage title" do
  def controller
    @controller = ImageTitleScreen.new(nav_bar: true)
  end

  it "should allow an image title" do
    controller.navigationItem.titleView.should.be.kind_of UIImageView
  end
end
