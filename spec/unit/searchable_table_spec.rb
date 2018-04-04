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
    controller.willPresentSearchController(controller.search_controller)
    controller.searching?.should == true
    controller.search_controller.searchBar.text = "New"
    controller.updateSearchResultsForSearchController(controller.search_controller)
    controller.tableView(controller.tableView, numberOfRowsInSection:0).should == 4
  end

  it "should allow ending searches" do
    controller.willPresentSearchController(controller.search_controller)
    controller.search_controller.searchBar.text = "North"
    controller.updateSearchResultsForSearchController(controller.search_controller)
    controller.tableView(controller.tableView, numberOfRowsInSection:0).should == 2

    controller.willDismissSearchController(controller.search_controller)
    controller.search_controller.searchBar.text = ""
    controller.updateSearchResultsForSearchController(controller.search_controller) # iOS calls this again
    controller.searching?.should == false
    controller.tableView(controller.tableView, numberOfRowsInSection:0).should == 50
  end

  it "should expose the search_string variable and clear it properly" do
    controller.willPresentSearchController(controller.search_controller)
    controller.search_controller.searchBar.text = "North"
    controller.updateSearchResultsForSearchController(controller.search_controller)

    controller.search_string.should == "north"
    controller.original_search_string.should == "North"

    controller.willDismissSearchController(controller.search_controller)
    controller.search_controller.searchBar.text = ""
    controller.updateSearchResultsForSearchController(controller.search_controller) # iOS calls this again

    controller.search_string.should == false
    controller.original_search_string.should == false
  end

  # FIXME: Can't figure out why this test passes in isolation, but fails when run after the other tests.
  # it "should call the start and stop searching callbacks properly" do
  #   controller.will_begin_search_called.should == nil
  #   controller.will_end_search_called.should == nil

  #   controller.willPresentSearchController(controller.search_controller)
  #   controller.will_begin_search_called.should == true

  #   controller.willDismissSearchController(controller.search_controller)
  #   controller.will_end_search_called.should == true
  # end

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
      @stabby_controller.willPresentSearchController(@stabby_controller.search_controller)
      @stabby_controller.search_controller.searchBar.text = "New Stabby"
      @stabby_controller.updateSearchResultsForSearchController(@stabby_controller.search_controller)
      @stabby_controller.tableView(@stabby_controller.tableView, numberOfRowsInSection:0).should == 4

      rows = @stabby_controller.promotion_table_data.search("New stabby")
      rows.first[:cells].length.should == 4
      rows.first[:cells].each do |row|
        # Starts with "New" and ends with "stabby"
        row[:properties][:searched_title].should.match(/^New(.+)?stabby$/)
      end
    end

    it "should allow searching for all the 'New' states using a symbol as a search proc" do
      @proc_controller.willPresentSearchController(@proc_controller.search_controller)
      @proc_controller.search_controller.searchBar.text = "New Symbol"
      @proc_controller.updateSearchResultsForSearchController(@proc_controller.search_controller)
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
      @stabby_controller.willPresentSearchController(@stabby_controller.search_controller)
      @stabby_controller.search_controller.searchBar.text = "Totally Bogus"
      @stabby_controller.updateSearchResultsForSearchController(@stabby_controller.search_controller)
      @stabby_controller.tableView(@stabby_controller.tableView, numberOfRowsInSection:0).should == 0
    end

    it "custom searches empty with symbol for proc if there is no match" do
      @proc_controller.willPresentSearchController(@proc_controller.search_controller)
      @proc_controller.search_controller.searchBar.text = "Totally Bogus"
      @proc_controller.updateSearchResultsForSearchController(@proc_controller.search_controller)
      @proc_controller.tableView(@proc_controller.tableView, numberOfRowsInSection:0).should == 0
    end

  end
end
