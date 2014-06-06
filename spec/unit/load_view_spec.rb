describe "load_view and on_load tests" do
  def screen
    @screen ||= LoadViewScreen.new
  end

  def table_screen
    @table_screen ||= LoadViewTableScreen.new
  end

  it "should call load_view when requesting the view" do
    screen.view.should.be.kind_of(MyView)
  end

  it "should call on_load after creating the view" do
    screen.view.should.be.kind_of(MyView)
    screen.view.backgroundColor.should == UIColor.redColor
  end

  it "should call load_view when requesting the view in a table screen" do
    table_screen.view.should.be.kind_of(MyTableView)
  end

  it "should call on_load after creating the view in a table screen" do
    table_screen.view.should.be.kind_of(MyTableView)
    table_screen.view.backgroundColor.should == UIColor.greenColor
  end
end
