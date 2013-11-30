describe "ProMotion::TestMapScreen functionality" do
  tests PM::TestMapScreen

  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @map ||= TestMapScreen.new(nav_bar: true)
    @map.will_appear
    @map.navigationController
  end

  def add_image_annotation
    ann = {
      longitude: -82.965972900392,
      latitude: 35.090648651124,
      title: "My Cool Image Pin",
      subtitle: "Image pin subtitle",
      image: UIImage.imageNamed("test.png")
    }
    @map.annotations.count.should == 5
    @map.add_annotation ann
    @map.set_region @map.region(coordinate: @map.annotations.last.coordinate, span: [0.05, 0.05])
  end

  after do
    @map = nil
  end

  it "should have a navigation bar" do
    @map.navigationController.should.be.kind_of(UINavigationController)
  end

  it "should have the map properly centered" do
    center_coordinate = @map.center
    center_coordinate.latitude.should.be.close 35.090648651123, 0.02
    center_coordinate.longitude.should.be.close -82.965972900391, 0.02
  end

  it "should move the map center" do
    @map.center = {latitude: 35.07496, longitude: -82.95916, animated: true}

    wait 0.75 do
      center_coordinate = @map.center
      center_coordinate.latitude.should.be.close 35.07496, 0.001
      center_coordinate.longitude.should.be.close -82.95916, 0.001
    end
  end

  it "should select an annotation" do
    @map.selected_annotations.should == nil
    @map.select_annotation @map.annotations.first
    wait 0.75 do
      @map.selected_annotations.count.should == 1
    end
  end

  it "should select an annotation by index" do
    @map.selected_annotations.should == nil
    @map.select_annotation_at 2
    wait 0.75 do
      @map.selected_annotations.count.should == 1
      @map.selected_annotations[0].should == @map.promotion_annotation_data[2]
    end
  end

  it "should select another annotation and check that the title is correct" do
    @map.selected_annotations.should == nil
    @map.select_annotation @map.annotations[1]
    wait 0.75 do
      @map.selected_annotations.count.should == 1
    end

    @map.selected_annotations.first.title.should == "Turtleback Falls"
    @map.selected_annotations.first.subtitle.should == "Nantahala National Forest"

  end

  it "should deselect selected annotations" do
    @map.select_annotation @map.annotations.last
    wait 0.75 do
      # @map.selected_annotations.count.should == 1
    end

    @map.deselect_annotations
    wait 0.75 do
      @map.selected_annotations.should == nil
    end
  end

  it "should add an annotation and be able to zoom immediately" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Something Else"
    }
    @map.annotations.count.should == 5
    @map.add_annotation ann
    @map.annotations.count.should == 6
    @map.set_region @map.region(coordinate: @map.annotations.last.coordinate, span: [0.05, 0.05])
    @map.select_annotation @map.annotations.last
  end

  it "should be able to overwrite all annotations" do
    anns = [{
      longitude: -122.029620,
      latitude: 37.331789,
      title: "My Cool Pin"
    },{
      longitude: -80.8498118 ,
      latitude: 35.2187218,
      title: "My Cool Pin"
    }]
    @map.annotations.count.should == 5
    @map.add_annotations anns
    @map.annotations.count.should == 2
  end

  it "should add an image based annotation" do
    add_image_annotation
    @map.annotations.count.should == 6

    # Checking that it conforms to the MKAnnotation protocol manually since this doesn't work in iOS 7:
    #  @map.annotations.last.conformsToProtocol(MKAnnotation).should.be.true
    # See this 8 month old bug - https://github.com/siuying/rubymotion-protocol-bug

    checking = @map.annotations.last
    %w(title subtitle coordinate).each do |method|
      defined?(checking.send(method.to_sym)).nil?.should.be.false
    end
  end

  it "should select an image annotation" do
    add_image_annotation
    @map.selected_annotations.should == nil
    @map.select_annotation @map.annotations.last
    wait 0.75 do
      @map.selected_annotations.count.should == 1
    end
  end

  it "should select an image annotation by index" do
    add_image_annotation
    @map.selected_annotations.should == nil
    @map.select_annotation_at 5
    wait 0.75 do
      @map.selected_annotations.count.should == 1
      @map.selected_annotations[0].should == @map.promotion_annotation_data[5]
    end
  end

  it "should select an image annotation and check that the title is correct" do
    add_image_annotation
    @map.selected_annotations.should == nil
    @map.select_annotation @map.annotations[5]
    wait 0.75 do
      @map.selected_annotations.count.should == 1
    end
    @map.selected_annotations.first.title.should == "My Cool Image Pin"
    @map.selected_annotations.first.subtitle.should == "Image pin subtitle"
  end

end
