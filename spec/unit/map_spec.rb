describe "map properties" do

  before do
    # Simulate AppDelegate setup of map screen
    @map = TestMapScreen.new modal: true, nav_bar: true
    @map.view_will_appear(false)
  end

  it "should store title" do
    @map.get_title.should == "Gorges State Park, NC"
  end

  it "should have 5 annotations" do
    @map.annotations.count.should == 5
  end

  it "should convert annotation hashes to MapViewAnnotations" do
    @map.annotations.each do |annotation|
      annotation.class.to_s.should == "NSKVONotifying_MapScreenAnnotation"
    end
  end

  it "should add an annotation" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Something Else"
    }
    @map.add_annotation(ann)
    @map.annotations.count.should == 6
  end

  it "should return custom annotation parameters" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Custom",
      another_value: "Mark"
    }
    @map.add_annotation(ann)
    @map.annotations.last.another_value.should == "Mark"
  end

  it "should return nil for custom annotation parameters that don't exist" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Custom",
      another_value: "Mark"
    }
    @map.add_annotation(ann)
    @map.annotations.last.another_value_fake.should == nil
  end

  it "should clear annotations" do
    @map.clear_annotations
    @map.annotations.count.should == 0
  end

  it "should geocode an address" do
    @map.lookup_infinite_loop
    wait_for_change @map, 'infinite_loop_points' do
      placemarks = @map.infinite_loop_points
      placemarks.count.should == 1
      placemarks.first.postalCode.should == "95014"
      placemarks.first.description.include?("Cupertino").should == true
    end
  end

end
