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

  describe "custom search" do
    before do
      @stabby_controller = TableScreenStabbySearchable.new
      @proc_controller   = TableScreenSymbolSearchable.new
    end

    after do
      @stabby_controller = nil
      @proc_controller = nil
    end

    it "should allow searching for all the 'New' states using a custom search proc" do
      @stabby_controller.searchDisplayController(@stabby_controller, shouldReloadTableForSearchString:"New Stabby")
      @stabby_controller.tableView(@stabby_controller.tableView, numberOfRowsInSection:0).should == 4
      rows = @stabby_controller.promotion_table_data.search("New stabby")
      rows.first[:cells].length.should == 4
      rows.first[:cells].each do |row|
        # Starts with "New" and ends with "stabby"
        row[:properties][:searched_title].should.match(/^New(.+)?stabby$/)
      end
    end

    it "should allow searching for all the 'New' states using a symbol as a search proc" do
      @proc_controller.searchDisplayController(@proc_controller, shouldReloadTableForSearchString:"New Symbol")
      cell_count = @proc_controller.tableView(@proc_controller.tableView, numberOfRowsInSection:0)
      cell_count.should == 4
      rows = @proc_controller.promotion_table_data.search("New Symbol")
      rows.first[:cells].length.should == 4
      rows.first[:cells].each do |row|
        # Starts with "New" and ends with "symbol"
        row[:properties][:searched_title].should.match(/^New(.+)?symbol$/)
      end
    end

    it "custom searches empty with stabby proc if there is no match" do
      @stabby_controller.searchDisplayController(@stabby_controller, shouldReloadTableForSearchString:"Totally Bogus")
      @stabby_controller.tableView(@stabby_controller.tableView, numberOfRowsInSection:0).should == 0
    end

    it "custom searches empty with symbol for proc if there is no match" do
      @proc_controller.searchDisplayController(@proc_controller, shouldReloadTableForSearchString:"Totally Bogus")
      @proc_controller.tableView(@proc_controller.tableView, numberOfRowsInSection:0).should == 0
    end

  end
end
