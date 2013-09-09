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

  it "should expose the search_string variable and clear it properly" do
    @controller.searchDisplayController(@controller, shouldReloadTableForSearchString:"North")

    @controller.search_string.should == "north"
    @controller.original_search_string.should == "North"

    @controller.searchDisplayControllerWillEndSearch(@controller)

    @controller.search_string.should == false
    @controller.original_search_string.should == false
  end

  it "should call the start and stop searching callbacks properly" do
    @controller.will_begin_search_called.should == nil
    @controller.will_end_search_called.should == nil

    @controller.searchDisplayControllerWillBeginSearch(@controller)
    @controller.searchDisplayController(@controller, shouldReloadTableForSearchString:"North")
    @controller.will_begin_search_called.should == true

    @controller.searchDisplayControllerWillEndSearch(@controller)
    @controller.will_end_search_called.should == true
  end

end
