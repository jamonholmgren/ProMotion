describe "ProMotion::TableScreen functionality" do
  tests PM::TestMiniTableScreen

  def table_screen
    @table_screen ||= begin
      t = TestMiniTableScreen.new(nav_bar: true)
      t
    end
  end

  def controller
    table_screen.navigationController
  end

  before do
    UIView.setAnimationsEnabled false
  end

  after do
    @table_screen = nil
  end

  it "no cells have fired on_reuse before scrolling" do
    ip = NSIndexPath.indexPathForRow(0, inSection: 0)
    cell = table_screen.tableView(table_screen.table_view, cellForRowAtIndexPath: ip)
    cell.on_reuse_fired.should.not == true
  end

  it "cell has fired on_reuse after scrolling" do
    ip = NSIndexPath.indexPathForRow(10, inSection: 0)
    table_screen.tableView.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPositionTop, animated: false)
    wait 0.001 do
      ip = NSIndexPath.indexPathForRow(0, inSection: 0)
      table_screen.tableView.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPositionTop, animated: false)

      cell = views(TestCell).first
      cell.on_reuse_fired.should == true
    end
  end

  it "no cells have fired prepare_for_reuse before scrolling" do
    ip = NSIndexPath.indexPathForRow(0, inSection: 0)
    cell = table_screen.tableView(table_screen.table_view, cellForRowAtIndexPath: ip)
    cell.prepare_for_reuse_fired.should.not == true
  end

  it "cell has fired prepare_for_reuse after scrolling" do
    ip = NSIndexPath.indexPathForRow(10, inSection: 0)
    table_screen.tableView.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPositionTop, animated: false)
    wait 0.001 do
      ip = NSIndexPath.indexPathForRow(0, inSection: 0)
      table_screen.tableView.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPositionTop, animated: false)

      cell = views(TestCell).first
      cell.prepare_for_reuse_fired.should == true
    end
  end

  it "should fire prepare_for_reuse before on_reuse" do
    ip = NSIndexPath.indexPathForRow(10, inSection: 0)
    table_screen.tableView.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPositionTop, animated: false)
    wait 0.001 do
      ip = NSIndexPath.indexPathForRow(0, inSection: 0)
      table_screen.tableView.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPositionTop, animated: false)

      cell = views(TestCell).first
      cell.prepare_for_reuse_time.should < cell.on_reuse_time
    end
  end
end
