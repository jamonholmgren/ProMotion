describe "PM::Table utils" do

  before do
    @subject = TestTableScreen.new
    @subject.on_load
    @subject.update_table_data
  end

  it "should convert an index path to a section index" do
    index_path = NSIndexPath.indexPathForRow(12, inSection:2)
    given = {index_path: index_path}
    expected = {
      index_path: index_path,
      section: 2,
      index: 12
    }

    @subject.index_path_to_section_index(given).should == expected
  end

  it "should properly determine if all members of an array are the same class" do
    @subject.array_all_members_of([1, 2, 3, 4], Fixnum).should == true
    @subject.array_all_members_of(["string", 'string2'], String).should == true
    @subject.array_all_members_of([:sym1, :sym2, :sym3], Symbol).should == true

    @subject.array_all_members_of([1, 2, 3, 4, 'String'], Fixnum).should == false
    @subject.array_all_members_of([4.4, 2], Fixnum).should == false
  end

end
