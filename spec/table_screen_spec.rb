describe "table screens" do
  
  describe "basic functionality" do

    before do
      UIView.setAnimationsEnabled false # avoid animation issues

      @screen = TableScreen.new
      @screen.on_load
    end
    
    it "should display 2 sections" do
      @screen.tableView.numberOfSections.should == 2
    end

    it "should have proper cell numbers" do
      @screen.tableView.numberOfRowsInSection(0).should == 3
      @screen.tableView.numberOfRowsInSection(1).should == 2
    end

    it "should have a placeholder image in the last cell" do
      index_path = NSIndexPath.indexPathForRow(1, inSection: 1)
      
      @screen.tableView(@screen.tableView, cellForRowAtIndexPath: index_path).imageView.class.should == UIImageView
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
      @screen.table_view.tableHeaderView.class.should == UISearchBar
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
      @screen.instance_variable_get("@refresh_control").class.should == UIRefreshControl
    end
    
    it "should respond to start_refreshing and end_refreshing" do
      @screen.respond_to?(:start_refreshing).should == true
      @screen.respond_to?(:end_refreshing).should == true
    end
    
    # Animations cause the refresh object to fail when tested. Test manually.
    
  end

end
