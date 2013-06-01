describe "table screens" do

  describe "basic functionality" do

    before do
      @screen = TestTableScreen.new
      @screen.on_load
    end

    it "should display some sections" do
      @screen.promotion_table_data.sections.should.be.kind_of(Array)
    end

    it "should have proper cell numbers" do
      @screen.tableView(@screen.tableView, numberOfRowsInSection:0).should == 6
      @screen.tableView(@screen.tableView, numberOfRowsInSection:1).should == 2
      @screen.tableView(@screen.tableView, numberOfRowsInSection:2).should == 4
    end

    it "should return a UITableViewCell" do
      index_path = NSIndexPath.indexPathForRow(1, inSection: 1)

      @screen.tableView(@screen.tableView, cellForRowAtIndexPath: index_path).should.be.kind_of UITableViewCell
    end

    it "should have a placeholder image in the last cell" do
      index_path = NSIndexPath.indexPathForRow(1, inSection: 1)

      @screen.tableView(@screen.tableView, cellForRowAtIndexPath: index_path).imageView.should.be.kind_of UIImageView
    end

    it "should display all images properly no matter how they were initialized" do
      section = @screen.promotion_table_data.sections.count - 1 # All the cells we want to test are in the last section

      @screen.tableView(@screen.tableView, numberOfRowsInSection:section).times do |i|
        index_path = NSIndexPath.indexPathForRow(i, inSection: section)

        @screen.tableView(@screen.tableView, cellForRowAtIndexPath: index_path).imageView.should.be.kind_of UIImageView

        # Test the corner radius on the first cell.
        if i == 0
          @screen.tableView(@screen.tableView, cellForRowAtIndexPath: index_path).imageView.layer.cornerRadius.to_f.should == 10.0
        end
      end
    end

  end

  describe "search functionality" do

    before do
      @screen = TableScreenSearchable.new
      @screen.on_load
    end

    it "should be searchable" do
      @screen.class.get_searchable.should == true
    end

    it "should create a search header" do
      @screen.table_view.tableHeaderView.should.be.kind_of UISearchBar
    end

  end

  describe "refresh functionality" do

    # Note this test only works if on iOS 6+ or when using CKRefreshControl.

    before do
      @screen = TableScreenRefreshable.new
      @screen.on_load
    end

    it "should be refreshable" do
      @screen.class.get_refreshable.should == true
    end

    it "should create a refresh object" do
      @screen.instance_variable_get("@refresh_control").should.be.kind_of UIRefreshControl
    end

    it "should respond to start_refreshing and end_refreshing" do
      @screen.respond_to?(:start_refreshing).should == true
      @screen.respond_to?(:end_refreshing).should == true
    end

    # Animations cause the refresh object to fail when tested. Test manually.

  end

end
