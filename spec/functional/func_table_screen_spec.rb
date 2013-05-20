describe "ProMotion::TableScreen functionality" do
  tests PM::TableScreen
  
  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @controller ||= TableScreen.new(nav_bar: true)
    @controller.on_load
    @controller.main_controller
  end
  
  after do
    @controller = nil
  end
  
  it "should have a navigation bar" do
    @controller.navigationController.is_a?(UINavigationController).should == true
  end
  
  it "should increment the tap counter on tap" do
    tap("Increment")
    @controller.tap_counter.should == 3
  end
  
  it "should add a new table cell on tap" do
    tap("Add New Row")
    view("Dynamically Added").class.should == UILabel
  end
  
  it "should do nothing when no action specified" do
    tap("Just another blank row")
    @controller.should == @controller
  end
  
  it "should increment the tap counter by one on tap" do 
    tap("Increment One")
    @controller.tap_counter.should == 1
  end
  
end