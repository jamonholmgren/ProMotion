describe "table screen basic functionality" do

  before do
    @screen = TableScreen.new
    @screen.on_load
  end

  tests TableScreen

  it "should display have 2 sections" do
    @screen.tableView.numberOfSections.should == 2
  end

  it "should have prope r cell numbers" do
    @screen.tableView.numberOfRowsInSection(0).should == 3
    @screen.tableView.numberOfRowsInSection(1).should == 2
  end

  # it "should run methods without arguments when tapping cell" do
  #   #cell = @screen.cell_at_section_and_index(0, 0)
  #   [1..10].each do |index|
  #     @screen.instance_variable_get("@tap_counter").should == index
  #     tap view("Increment")
  #   end
  # end

  # it "should have a placeholder image in the last cell" do
  #   @screen.cell_at_section_and_index(1,1).imageView.should.be.a UIImage
  # end

  # it "should add a new cell to first section" do
  #   tap "Add New Row"
  #   wait 0.2 do
  #     @screen.tableView.numberOfRowsInSection(0).should == 4
  #   end
  # end

end
