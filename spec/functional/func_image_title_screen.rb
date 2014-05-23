describe "ProMotion::Screen UIImage title functionality" do
  tests PM::Screen

  def controller
    @controller ||= ImageTitleScreen.new(nav_bar: true)
    @controller.navigationController
  end

  it "should allow an image title" do
    @controller.navigationItem.titleView.should.be.kind_of UIImageView
  end
end
