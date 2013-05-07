class TableScreen < ProMotion::SectionedTableScreen

  def on_load
    @tap_counter ||= 0
  end

  def table_data
    [{
      title: "Your Account",
      cells: [
        { title: "Increment", action: :increment_counter_by, arguments: { number: 3 } },
        { title: "Add New Row", action: :add_tableview_row, accessibilityLabel: "Add New Row" },
        { title: "Just another blank row" }
      ]
    }, {
      title: "App Stuff",
      cells: [
        { title: "Increment One", action: :increment_counter },
        { title: "Feedback", remote_image: { url: "http://placekitten.com/100/100", placeholder: "some-local-image", size: 50, radius: 15 } }
      ]
    }]
  end

  def edit_profile(args={})
    args[:id]
  end

  def add_tableview_row
    @data[0][:cells] << {
      title: "Dynamically Added"
    }
    update_table_data
  end

  def increment_counter
    @tap_counter += 1
  end

  def increment_counter_by(args)
    @tap_counter = @tap_counter + args[:number]
  end
  
  def tap_counter
    @tap_counter
  end


end