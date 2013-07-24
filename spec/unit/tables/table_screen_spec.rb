describe "table screens" do

  describe "basic functionality" do

    before do
      @screen = TestTableScreen.new
      @screen.on_load
    end

    it "should add an image right nav bar button" do
      image = UIImage.imageNamed("list.png")
      # @screen.set_nav_bar_button :right, image: image, action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
      @screen.navigationItem.rightBarButtonItem.image.class.should == UIImage
      @screen.navigationItem.rightBarButtonItem.image.should == image
    end

    it "should display some sections" do
      @screen.promotion_table_data.sections.should.be.kind_of(Array)
    end

    it "should have proper cell numbers" do
      @screen.tableView(@screen.tableView, numberOfRowsInSection:0).should == 7
      @screen.tableView(@screen.tableView, numberOfRowsInSection:1).should == 2
      @screen.tableView(@screen.tableView, numberOfRowsInSection:2).should == 4
      @screen.tableView(@screen.tableView, numberOfRowsInSection:3).should == 3
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
      @screen.tableView(@screen.tableView, numberOfRowsInSection:2).times do |i|
        index_path = NSIndexPath.indexPathForRow(i, inSection:2)

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

  describe 'test PM::TableScreen\'s method call order' do
    before do
      class MethodCallOrderTestTableScreen < PM::TableScreen
        def table_data; @table_data ||= []; end
        def on_load
          @table_data = [{cells: [ title: 'cell 1' ]}]
          update_table_data
        end
      end
    end

    it 'should not raise error at load view' do
      proc { @screen = MethodCallOrderTestTableScreen.new }.should.not.raise(NoMethodError)
    end
  end

end

