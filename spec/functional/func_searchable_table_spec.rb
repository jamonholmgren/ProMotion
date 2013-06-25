describe "Searchable table spec" do
  tests TableScreenSearchable

  # Override controller to properly instantiate
  def controller
    @controller ||= TableScreenSearchable.new(nav_bar: true)
    @controller.on_load
    @controller.navigation_controller
  end

  it "should be rotated in portrait mode" do
    rotate_device to: :portrait, button: :bottom
    true.should == true
  end

  it "should show all 50 states" do
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 50
  end

  it "should allow searching for all the 'New' states" do
    @controller.searchDisplayController(@controller, shouldReloadTableForSearchString:"New")
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 4
  end

  it "should allow ending searches" do
    @controller.searchDisplayController(@controller, shouldReloadTableForSearchString:"North")
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 2
    @controller.searchDisplayControllerWillEndSearch(@controller)
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 50
  end

end
