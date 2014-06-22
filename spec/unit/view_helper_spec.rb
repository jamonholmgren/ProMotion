describe "view helpers" do

  def equal_rect(rect)
    ->(obj) { CGRectEqualToRect obj, rect }
  end

  before do
    @dummy = UIView.alloc.initWithFrame CGRectZero
    @dummy.extend ProMotion::Styling
  end

  it "should allow you to set attributes" do
    @dummy.set_attributes @dummy, backgroundColor: UIColor.redColor
    @dummy.backgroundColor.should == UIColor.redColor
  end

  it "should allow you to set nested attributes" do
    layered_view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 10, 10))

    @dummy.set_attributes layered_view, {
      layer: {
        backgroundColor: UIColor.redColor.CGColor
      }
    }

    layered_view.layer.backgroundColor.should == UIColor.redColor.CGColor
  end

  it "should allow you to set multiple nested attributes" do
    mask_layer = CAShapeLayer.layer
    layered_view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 10, 10))
    layered_view.layer.mask = mask_layer
    @dummy.set_attributes layered_view, {
      layer: {
        mask: {
          backgroundColor: UIColor.redColor.CGColor
        }
      }
    }

    layered_view.layer.mask.backgroundColor.should == UIColor.redColor.CGColor
  end

  it "should allow you to set an accessor to a hash" do
    view_with_attr = CustomTitleView.new
    @dummy.set_attributes view_with_attr, { title: { jamon: 1 } }
    view_with_attr.title.should == { jamon: 1 }
  end

  it "should allow you to set snake_case attributes" do
    layered_view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 10, 10))

    @dummy.set_attributes layered_view, {
      layer: {
        background_color: UIColor.redColor.CGColor
      },
      content_mode: UIViewContentModeBottom
    }

    layered_view.contentMode.should == UIViewContentModeBottom
    layered_view.layer.backgroundColor.should == UIColor.redColor.CGColor
  end


  context "content sizing" do

    before do
      @child = UIView.alloc.initWithFrame([[20,100],[300,380]])
      @dummy.addSubview @child
    end

    describe "content_height" do

      it "should return content height" do
        @dummy.content_height(@dummy).should == 480
      end

      it "should ignore hidden subviews" do
        @child.hidden = true
        @dummy.content_height(@dummy).should == 0
      end

    end

    describe "content_width" do

      it "should return content width" do
        @dummy.content_width(@dummy).should == 320
      end

      it "should ignore hidden subviews" do
        @child.hidden = true
        @dummy.content_width(@dummy).should == 0
      end

    end

  end

end
