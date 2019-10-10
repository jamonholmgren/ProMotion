class UpdateTestTableScreen < PM::TableScreen
  row_height 77

  def table_data; @table_data ||= []; end
  def on_load
    @table_data = [{cells: []}]
    update_table_data
  end

  def make_more_cells
    @table_data = [{cells: [{title: "Cell 1"},{title: "Cell 2"}]}]
  end

  def change_cells
    @table_data = [{cells: [{title: "Cell A"},{title: "Cell B"}]}]
  end

  def first_cell_title
    cell_title(0)
  end

  def second_cell_title
    cell_title(1)
  end

  def cell_title(index)
    ip = NSIndexPath.indexPathForRow(index, inSection:0)
    table_view.cellForRowAtIndexPath(ip).textLabel.text
  end
end
