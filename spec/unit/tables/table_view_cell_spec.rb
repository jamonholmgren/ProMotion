describe "PM::TableViewCell" do
  
  before do
    @subject = TestTableScreen.new
    @subject.on_load
    @basic_cell = { title: "Basic", action: :basic_cell_tapped, arguments: { id: 1 } }
  end
  
  it "should do nothing" do
    1.should == 1
  end
  
  it "should set the section title" do
    @subject.mock! :table_data do
      [{
        title: "Table cell group 1",
        cells: [ @basic_cell.dup ]
      },{
        title: "Table cell group 2",
        cells: [ @basic_cell.dup ]
      },{
        title: "Table cell group 3",
        cells: [ @basic_cell.dup ]
      }]
    end
    
    @subject.update_table_data
    @subject.tableView(@subject.table_view, titleForHeaderInSection:0).should == "Table cell group 1"
    @subject.tableView(@subject.table_view, titleForHeaderInSection:1).should == "Table cell group 2"
    @subject.tableView(@subject.table_view, titleForHeaderInSection:2).should == "Table cell group 3"
  end
  
end

# def table_data
#   [{
#     title: "Table cell group 1",
#     cells: [{
#       title: "Simple cell",
#       action: :this_cell_tapped,
#       arguments: { id: 4 }
#     }, {
#       title: "Crazy Full Featured Cell",
#       subtitle: "This is way too huge..see note",
#       arguments: { data: [ "lots", "of", "data" ] },
#       action: :tapped_cell_1,
#       height: 50, # manually changes the cell's height
#       cell_style: UITableViewCellStyleSubtitle,
#       cell_identifier: "Cell",
#       cell_class: PM::TableViewCell,
#       masks_to_bounds: true,
#       background_color: UIColor.whiteColor,
#       selection_style: UITableViewCellSelectionStyleGray,
#       cell_class_attributes: {
#         # any Obj-C attributes to set on the cell
#         backgroundColor: UIColor.whiteColor
#       },
#       accessory: :switch, # currently only :switch is supported
#       accessory_view: @some_accessory_view,
#       accessory_type: UITableViewCellAccessoryCheckmark,
#       accessory_checked: true, # whether it's "checked" or not
#       image: { image: UIImage.imageNamed("something"), radius: 15 },
#       remote_image: {  # remote image, requires SDWebImage CocoaPod
#         url: "http://placekitten.com/200/300", placeholder: "some-local-image",
#         size: 50, radius: 15
#       },
#       subviews: [ @some_view, @some_other_view ] # arbitrary views added to the cell
#     }]
#   }, {
#     title: "Table cell group 2",
#     cells: [{
#       title: "Log out",
#       action: :log_out
#     }]
#   }]
# end