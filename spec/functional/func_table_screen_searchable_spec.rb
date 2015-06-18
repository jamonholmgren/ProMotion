describe "ProMotion::TableScreen searchable functionality" do
  tests TableScreenSymbolSearchableNoResults

  def table_screen
    @table_screen ||= TableScreenSymbolSearchableNoResults.new(nav_bar: true)
  end

  after { @table_screen = nil }

  it "should display a custom message when there are no results" do
    table_screen.searchDisplayControllerWillBeginSearch(table_screen.searchDisplayController)
    table_screen.searchDisplayController(table_screen.searchDisplayController, shouldReloadTableForSearchString:"supercalifragilisticexpialidocious")
    table_screen.update_table_data

    results_label = table_screen.searchDisplayController.searchResultsTableView.subviews.detect{|v| v.is_a?(UILabel)}
    wait_for_change results_label, 'text' do
      results_label.text.should == "Nada!"
    end
  end
end
