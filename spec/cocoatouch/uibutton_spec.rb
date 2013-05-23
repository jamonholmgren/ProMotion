describe "UIButton" do
  before do
    @button = UIButton.alloc.init
  end

  it "should assign the background images depending on states" do
    image = UIImage.alloc.init
    @button.backgroundImageForState(UIControlStateSelected).should == nil
    @button.background_images({image: image, state: UIControlStateSelected})
    @button.backgroundImageForState(UIControlStateSelected)
    @button.backgroundImageForState(UIControlStateSelected).should == image
  end

  it "should assign the targets images depending on events" do
    @button.actionsForTarget(@button, forControlEvent: UIControlEventTouchUpInside).should == nil
    @button.targets({target: @button, action: :button_clicked, event: UIControlEventTouchUpInside})
    @button.actionsForTarget(@button, forControlEvent: UIControlEventTouchUpInside).should == ["button_clicked"]
  end

end