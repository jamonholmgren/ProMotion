class TestTableScreen < ProMotion::TableScreen

  attr_accessor :tap_counter, :cell_was_deleted

  def promotion_table_data
    @promotion_table_data
  end

  def on_load
    self.tap_counter = 0
    set_attributes self.view, { backgroundView: nil, backgroundColor: UIColor.whiteColor }
    set_nav_bar_right_button UIImage.imageNamed("list.png"), action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
  end

  def table_data
    @data ||= [{
      title: "Your Account",
      cells: [
        { title: "Increment", action: :increment_counter_by, arguments: {number: 3} },
        { title: "Add New Row", action: :add_tableview_row },
        { title: "Delete the row below", action: :delete_cell, arguments: {section: 0, row:3} },
        { title: "Just another deletable blank row", editing_style: :delete },
        { title: "A non-deletable blank row", editing_style: :delete },
        { title: "Delete the row below with an animation", action: :delete_cell, arguments: {animated: true, section: 0, row:5 } },
        { title: "Just another blank row" }
      ]
    }, {
      title: "App Stuff",
      cells: [
        { title: "Increment One", action: :increment_counter },
        { title: "Feedback", cell_identifier: "ImagedCell", remote_image: { url: "http://placekitten.com/100/100", placeholder: "some-local-image", size: 50, radius: 15 } }
      ]
    }, {
      title: "Image Tests",
      cells: [
        { title: "Image Test 1", cell_identifier: "ImagedCell", image: {image: UIImage.imageNamed("list.png"), radius: 10} },
        { title: "Image Test 2", cell_identifier: "ImagedCell", image: {image: "list.png"} },
        { title: "Image Test 3", cell_identifier: "ImagedCell", cell_identifier: "ImagedCell", image: UIImage.imageNamed("list.png") },
        { title: "Image Test 4", image: "list.png" },
      ]
    }, {
      title: "Cell Accessory Tests",
      cells: [{
          title: "Switch With Action",
          accessory: {
              view: :switch,
              action: :increment_counter,
              accessibility_label: "switch_1"
            } ,
        }, {
          title: "Switch With Action And Parameters",
          accessory: {
            view: :switch,
            action: :increment_counter_by,
            arguments: { number: 3 },
            accessibility_label: "switch_2"
          } ,
        }, {
          title: "Switch With Cell Tap, Switch Action And Parameters",
          accessory:{
            view: :switch,
            action: :increment_counter_by,
            arguments: { number: 3 },
            accessibility_label: "switch_3"
          },
          action: :increment_counter_by,
          arguments: { number: 10 }
        }]
    }]
  end

  def edit_profile(args={})
    args[:id]
  end

  def add_tableview_row(args={})
    @data[0][:cells] << {
      title: "Dynamically Added"
    }
    update_table_data
  end

  def delete_cell(args={})
    if args[:animated]
      delete_row(NSIndexPath.indexPathForRow(args[:row], inSection:args[:section]))
    else
      @data[args[:section]][:cells].delete_at args[:row]
      update_table_data
    end
  end

  def on_cell_deleted(cell)
    if cell[:title] == "A non-deletable blank row"
      false 
    else
      self.cell_was_deleted = true
    end
  end

  def increment_counter
    self.tap_counter = self.tap_counter + 1
  end

  def increment_counter_by(args={})
    self.tap_counter = self.tap_counter + args[:number]
  end

  def custom_accessory_view
    set_attributes UIView.new, {
      background_color: UIColor.orangeColor
    }
  end

  def scroll_to_bottom
    if table_view.contentSize.height > table_view.frame.size.height
        offset = CGPointMake(0, table_view.contentSize.height - table_view.frame.size.height)
        table_view.setContentOffset(offset, animated:false)
    end
  end

end
