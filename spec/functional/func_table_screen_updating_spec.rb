describe "ProMotion::TableScreen updating functionality" do
  tests PM::UpdateTestTableScreen

  it 'should update a single row in the table view' do
    table_screen = UpdateTestTableScreen.new
    table_screen.make_more_cells
    table_screen.update_table_data
    table_screen.change_cells

    table_screen.first_cell_title.should == "Cell 1"
    table_screen.second_cell_title.should == "Cell 2"

    table_screen.update_table_data(NSIndexPath.indexPathForRow(0, inSection:0))

    table_screen.first_cell_title.should == "Cell A"
    table_screen.second_cell_title.should == "Cell 2"
  end

  it 'should allow multiple formats of index paths to be passed' do
    table_screen = UpdateTestTableScreen.new
    table_screen.make_more_cells
    table_screen.update_table_data
    table_screen.change_cells

    # Single NSIndexPath
    Proc.new {
      table_screen.update_table_data(NSIndexPath.indexPathForRow(0, inSection:0))
    }.should.not.raise(StandardError)

    # Array of NSIndexPaths
    Proc.new {
    table_screen.update_table_data([NSIndexPath.indexPathForRow(0, inSection:0), NSIndexPath.indexPathForRow(1, inSection:0)])
    }.should.not.raise(StandardError)

    # # Hash with single NSIndexPath
    Proc.new {
      table_screen.update_table_data({index_paths: NSIndexPath.indexPathForRow(0, inSection:0)})
    }.should.not.raise(StandardError)

    # Hash with array of NSIndexPaths
    Proc.new {
      table_screen.update_table_data({index_paths: [NSIndexPath.indexPathForRow(0, inSection:0), NSIndexPath.indexPathForRow(1, inSection:0)]})
    }.should.not.raise(StandardError)

    # Hash with NSIndexPath and row animation
    Proc.new {
      table_screen.update_table_data({index_paths: NSIndexPath.indexPathForRow(0, inSection:0), animation: UITableViewRowAnimationFade})
    }.should.not.raise(StandardError)
  end
end
