describe "view helpers" do

  def equal_rect(rect)
    ->(obj) { CGRectEqualToRect obj, rect }
  end

  before do
    @dummy = UIView.alloc.initWithFrame CGRectZero
    @dummy.extend ProMotion::ViewHelper
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


  describe "content height" do

    before do
      @child = UIView.alloc.initWithFrame([[20,100],[300,380]])
      @dummy.addSubview @child
    end

    it "should return content height" do
      @dummy.content_height(@dummy).should == 480
    end

    it "should ignore hidden subviews" do
      @child.hidden = true
      @dummy.content_height(@dummy).should == 0
    end

  end

  describe "set_easy_attributes" do

    before do
      @dummy = UIView.alloc.initWithFrame CGRectZero
      @dummy.extend ProMotion::ViewHelper
      
      @parent = UIView.alloc.initWithFrame(CGRectMake(0, 0, 320, 480))
      @child = UIView.alloc.initWithFrame(CGRectZero)
    end

    it "Should set the autoresizingMask for all" do
      @dummy.set_easy_attributes @parent, @child, {
        resize: [:left, :right, :top, :bottom, :width, :height]
      }

      mask =  UIViewAutoresizingFlexibleLeftMargin | 
              UIViewAutoresizingFlexibleRightMargin | 
              UIViewAutoresizingFlexibleTopMargin | 
              UIViewAutoresizingFlexibleBottomMargin | 
              UIViewAutoresizingFlexibleWidth | 
              UIViewAutoresizingFlexibleHeight

      @child.autoresizingMask.should == mask
    end

    it "Should set the autoresizingMask for half" do
      @dummy.set_easy_attributes @parent, @child, {
        resize: [:left, :right, :top]
      }

      mask =  UIViewAutoresizingFlexibleLeftMargin | 
              UIViewAutoresizingFlexibleRightMargin | 
              UIViewAutoresizingFlexibleTopMargin

      @child.autoresizingMask.should == mask
    end

    it "Should set the autoresizingMask for the second half" do
      @dummy.set_easy_attributes @parent, @child, {
        resize: [:bottom, :width, :height]
      }

      mask =  UIViewAutoresizingFlexibleBottomMargin | 
              UIViewAutoresizingFlexibleWidth | 
              UIViewAutoresizingFlexibleHeight

      @child.autoresizingMask.should == mask
    end

    it "Should not set the autoresizingMask" do
      @dummy.set_easy_attributes @parent, @child, {}

      mask =  UIViewAutoresizingNone

      @child.autoresizingMask.should == mask
    end

    it "Should create a frame" do
      @dummy.set_easy_attributes @parent, @child, {
        left: 10,
        top: 20,
        width: 100,
        height: 50
      }

      @child.frame.should == CGRectMake(10, 20, 100, 50)
    end

  end

end
