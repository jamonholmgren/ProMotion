describe "Searchable table spec" do
  # Override controller to properly instantiate
  def controller
    @controller ||= begin
      c = TableScreenSearchable.new
      c.on_load
      c
    end
  end

  after do
    @controller = nil
  end

  it "should show all 50 states" do
    controller.tableView(controller.tableView, numberOfRowsInSection:0).should == 50
  end

  it "should allow searching for all the 'New' states" do
    controller.searchDisplayController(controller, shouldReloadTableForSearchString:"New")
    controller.tableView(controller.tableView, numberOfRowsInSection:0).should == 4
  end

  it "should allow ending searches" do
    controller.searchDisplayController(controller, shouldReloadTableForSearchString:"North")
    controller.tableView(controller.tableView, numberOfRowsInSection:0).should == 2
    controller.searchDisplayControllerWillEndSearch(controller)
    controller.tableView(controller.tableView, numberOfRowsInSection:0).should == 50
  end

  it "should expose the search_string variable and clear it properly" do
    controller.searchDisplayController(controller, shouldReloadTableForSearchString:"North")

    controller.search_string.should == "north"
    controller.original_search_string.should == "North"

    controller.searchDisplayControllerWillEndSearch(controller)

    controller.search_string.should == false
    controller.original_search_string.should == false
  end

  it "should call the start and stop searching callbacks properly" do
    controller.will_begin_search_called.should == nil
    controller.will_end_search_called.should == nil

    controller.searchDisplayControllerWillBeginSearch(controller)
    controller.searchDisplayController(controller, shouldReloadTableForSearchString:"North")
    controller.will_begin_search_called.should == true

    controller.searchDisplayControllerWillEndSearch(controller)
    controller.will_end_search_called.should == true
  end

  it "should set the row height of the search display to match the source table row height" do
    tableView = UITableView.alloc.init
    tableView.mock!(:rowHeight=)
    controller.searchDisplayController(controller, didLoadSearchResultsTableView: tableView)
  end

  context "Has a nav bar" do

    it "should hide the nav_bar when searching" do
      screen = TableScreenSearchable.new(nav_bar: true)
      screen.navigationController.mock!("setNavigationBarHidden:animated:") do |hid, anim|
        hid.should.be.true
        anim.should.be.true
      end
      screen.searchDisplayControllerWillBeginSearch(_)
    end

    it "should show the nav_bar when done searching" do
      screen = TableScreenSearchable.new(nav_bar: true)
      screen.navigationController.mock!("setNavigationBarHidden:animated:") do |hid, anim|
        hid.should.be.false
        anim.should.be.true
      end
      screen.searchDisplayControllerWillEndSearch(nil)
    end

  end

end
