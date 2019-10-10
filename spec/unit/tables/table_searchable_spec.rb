describe "table screen searchable functionality" do
  before do
    @screen = TableScreenSearchable.new
    @screen.on_load
  end

  it "should be searchable" do
    @screen.class.get_searchable.should == true
  end

  # Older than iOS 11 tests
  if TestHelper.lt_ios11
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
      screen.tableView.contentOffset.should == CGPointMake(0, screen.tableView.tableHeaderView.frame.size.height)
    end
  end
end
