describe "PM::Table module indexable" do

  before do
    @screen = TableScreenIndexable.new
  end

  it "should automatically return the first letter of each section" do
    result = %w{ A G M O S U }
    @screen.sectionIndexTitlesForTableView(@screen.table_view).should == result
  end

end

describe "PM::Table module indexable/searchable" do

  before do
    @screen = TableScreenIndexableSearchable.new
  end

  it "should automatically return the first letter of each section" do
    result = %w{ {search} A G M O S U }
    @screen.sectionIndexTitlesForTableView(@screen.table_view).should == result
  end

end
