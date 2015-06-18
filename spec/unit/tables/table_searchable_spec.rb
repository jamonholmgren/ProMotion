describe "table screen searchable functionality" do
  before do
    @screen = TableScreenSearchable.new
    @screen.on_load
  end

  it "should be searchable" do
    @screen.class.get_searchable.should == true
  end

  it "should create a search header" do
    @screen.tableView.tableHeaderView.should.be.kind_of UISearchBar
  end

  it "should not hide the search bar initally by default" do
    @screen.tableView.contentOffset.should == CGPointMake(0,0)
  end

  it "should allow hiding the search bar initally" do
    class HiddenSearchScreen < TableScreenSearchable
      searchable hide_initially: true
    end
    screen = HiddenSearchScreen.new
    screen.on_load
    screen.tableView.contentOffset.should == CGPointMake(0,screen.searchDisplayController.searchBar.frame.size.height)
  end

  it "should display a custom message when there are no results" do
    table_screen = TableScreenSymbolSearchableNoResults.new
    table_screen.on_load

    table_screen.searchDisplayControllerWillBeginSearch(table_screen.searchDisplayController)
    table_screen.searchDisplayController(table_screen.searchDisplayController, shouldReloadTableForSearchString:"supercalifragilisticexpialidocious")
    table_screen.update_table_data

    results_label = table_screen.searchDisplayController.searchResultsTableView.subviews.detect{|v| v.is_a?(UILabel)}
    wait_for_change results_label, 'text' do
      results_label.text.should == "Nada!"
    end
  end
end
