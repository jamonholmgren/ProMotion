describe "ProMotion::TestTableScreen functionality" do
  tests PM::TestTableScreen

  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @controller ||= TestTableScreen.new(nav_bar: true)
    @controller.on_load
    @controller.navigation_controller
  end

  after do
    @controller = nil
  end

  it "should have a navigation bar" do
    @controller.navigationController.should.be.kind_of(UINavigationController)
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

  it "should delete the specified row from the table view on tap" do
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 6
    tap("Delete the row below")
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 5
  end

  it "should delete the specified row from the table view on tap with an animation" do
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 6
    tap("Delete the row below with an animation")
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 5
  end

  it "should call a method when the switch is flipped" do
    @controller.scroll_to_bottom
    tap "switch_1"
    @controller.tap_counter.should == 1
  end

  it "should call the method with arguments when the switch is flipped and when the cell is tapped" do
    @controller.scroll_to_bottom
    tap "switch_3"
    @controller.tap_counter.should == 3

    tap "Switch With Cell Tap, Switch Action And Parameters"
    @controller.tap_counter.should == 13
  end

  it "should call the method with arguments when the switch is flipped" do
    @controller.scroll_to_bottom
    tap "switch_2"
    @controller.tap_counter.should == 3
  end

end
