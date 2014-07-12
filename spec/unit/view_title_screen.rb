describe "ProMotion::Screen UIView title functionality" do
  def controller
    @controller ||= ViewTitleScreen.new(nav_bar: true)
  end

  it "should allow a non-image UIView title" do
    controller.navigationItem.titleView.should.not.be.kind_of UIImageView
    controller.navigationItem.titleView.should.be.kind_of UIView
  end
end
