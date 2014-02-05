describe "ProMotion::Screen UIView title functionality" do
  tests PM::Screen

  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @image_title_screen ||= ViewTitleScreen.new(nav_bar: true)
    @root_screen = @image_title_screen
    @image_title_screen.navigationController
  end

  after do
    @controller = nil
    @root_screen = nil
  end

  it "should allow an image title" do
    @root_screen.navigationItem.titleView.should.not.be.kind_of UIImageView
    @root_screen.navigationItem.titleView.should.be.kind_of UIView
  end
end
