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

    it "sets the auto row height and estimated row height properly" do
      @screen.view.rowHeight.should == UITableViewAutomaticDimension if TestHelper.gte_ios8
      @screen.view.rowHeight.should == 97 unless TestHelper.gte_ios8
      @screen.view.estimatedRowHeight.should == 97
    end

    it "sets the fixed row height properly" do
      screen = UpdateTestTableScreen.new

      screen.view.rowHeight.should == 77
      screen.view.estimatedRowHeight.should == 77
    end
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

  describe "test PM::TableScreen's updating functionality" do
    it 'should update the table data when update_table_data is called' do
      @screen = UpdateTestTableScreen.new
      @screen.tableView(@screen.tableView, numberOfRowsInSection:0).should == 0
      @screen.make_more_cells

      # We made them, but they shouldn't be in the table yet.
      @screen.tableView(@screen.tableView, numberOfRowsInSection:0).should == 0

      @screen.update_table_data
      @screen.tableView(@screen.tableView, numberOfRowsInSection:0).should == 2
    end

  end

  describe "test PM::TableScreen's moving cells functionality" do
    before do
      UIView.animationsEnabled = false
      @screen = TestTableScreen.new
      @screen.on_load
    end

    it "should allow the table screen to enter editing mode" do
      @screen.isEditing.should == false
      @screen.edit_mode(enabled:true, animated:false)
      @screen.isEditing.should == true
    end

    it "should use a convenience method to see if the table is editing" do
      @screen.isEditing.should == @screen.edit_mode?
      @screen.edit_mode(enabled:true, animated:false)
      @screen.isEditing.should == @screen.edit_mode?
    end

    it "should toggle editing mode" do
      @screen.edit_mode?.should == false
      @screen.toggle_edit_mode(false)
      @screen.edit_mode?.should == true
      @screen.toggle_edit_mode(false)
      @screen.edit_mode?.should == false
    end

    it "should return true for cells that are moveable" do
      # Index path with :moveable = true
      index_path = NSIndexPath.indexPathForRow(0, inSection:4)
      @screen.tableView(@screen.tableView, canMoveRowAtIndexPath: index_path).should == true

      # Index path with no :moveable set
      index_path = NSIndexPath.indexPathForRow(2, inSection:4)
      @screen.tableView(@screen.tableView, canMoveRowAtIndexPath: index_path).should == false

      # Index path with :moveable = false
      index_path = NSIndexPath.indexPathForRow(4, inSection:4)
      @screen.tableView(@screen.tableView, canMoveRowAtIndexPath: index_path).should == false
    end

    it "should rearrange the data object when a cell is moved" do
      move_from = NSIndexPath.indexPathForRow(0, inSection:4)
      move_to   = NSIndexPath.indexPathForRow(2, inSection:4)

      @screen.promotion_table_data.section(4)[:cells].map{|c| c[:title]}.should == [
        'Cell 1',
        'Cell 2',
        'Cell 3',
        'Cell 4',
        'Cell 5'
      ]
      @screen.tableView(@screen.tableView, moveRowAtIndexPath:move_from, toIndexPath:move_to)
      @screen.promotion_table_data.section(4)[:cells].map{|c| c[:title]}.should == [
        'Cell 2',
        'Cell 3',
        'Cell 1',
        'Cell 4',
        'Cell 5'
      ]
    end

    it "should call :cell_moved when moving a cell" do
      move_from = NSIndexPath.indexPathForRow(0, inSection:4)
      move_to   = NSIndexPath.indexPathForRow(2, inSection:4)

      @screen.cell_was_moved.nil?.should == true
      @screen.tableView(@screen.tableView, moveRowAtIndexPath:move_from, toIndexPath:move_to)
      @screen.cell_was_moved.is_a?(Hash).should == true

      cell = @screen.cell_was_moved

      cell[:paths][:from].should == move_from
      cell[:paths][:to].should == move_to

      cell[:cell][:title].should == "Cell 1"
    end

    it "should allow cells to move to other sections" do
      move_from = NSIndexPath.indexPathForRow(1, inSection:4)
      move_to   = NSIndexPath.indexPathForRow(0, inSection:3)

      moving_to = @screen.tableView(@screen.tableView, targetIndexPathForMoveFromRowAtIndexPath:move_from, toProposedIndexPath:move_to)

      moving_to.should == move_to
    end

    it "should not allow cells to move to other sections" do
      move_from = NSIndexPath.indexPathForRow(0, inSection:4)
      move_to   = NSIndexPath.indexPathForRow(0, inSection:3)

      moving_to = @screen.tableView(@screen.tableView, targetIndexPathForMoveFromRowAtIndexPath:move_from, toProposedIndexPath:move_to)

      moving_to.should == move_from
    end

  end

end
