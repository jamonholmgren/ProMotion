describe "ProMotion::TestTableScreen functionality" do
  tests PM::TestTableScreen

  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @controller ||= TestTableScreen.new(nav_bar: true)
    @controller.on_load
    @controller.navigation_controller
  end

  it "should have a navigation bar" do
    @controller.navigationController.should.be.kind_of(UINavigationController)
  end

  it "should increment the tap counter on tap" do
    tap("Increment")
    @controller.tap_counter.should == 3
  end

  it "should add a new table cell on tap" do
    tap("Add New Row")
    view("Dynamically Added").class.should == UILabel
  end

  it "should do nothing when no action specified" do
    tap("Just another blank row")
    @controller.should == @controller
  end

  it "should increment the tap counter by one on tap" do
    tap("Increment One")
    @controller.tap_counter.should == 1
  end

  it "should delete the specified row from the table view on tap" do
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 7
    tap("Delete the row below")
    wait 0.3 do
      @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 6
    end
  end

  it "should delete the specified row from the table view on tap with an animation" do
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 7
    tap("Delete the row below with an animation")
    wait 0.3 do
      @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 6
    end
  end

  # TODO: Why is it so complicated to find the delete button??
  it "should use editing_style to delete the table row" do
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 7
    @controller.cell_was_deleted.should != true
    flick("Just another deletable blank row", :to => :left)

    wait 0.25 do
      # Tap the delete button
      view('Just another deletable blank row').superview.superview.subviews.each do |subview|
        if subview.class == UITableViewCellDeleteConfirmationControl
          tap subview
          wait 0.25 do
            @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 6
            @controller.cell_was_deleted.should == true
          end
        end
      end
    end
  end

  it "should not allow deleting if on_cell_delete returns `false`" do
    @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 7
    @controller.cell_was_deleted.should != true
    flick("A non-deletable blank row", :to => :left)

    wait 0.25 do
      # Tap the delete button
      view('A non-deletable blank row').superview.superview.subviews.each do |subview|
        if subview.class == UITableViewCellDeleteConfirmationControl
          tap subview
          wait 0.25 do
            @controller.tableView(@controller.tableView, numberOfRowsInSection:0).should == 7
            @controller.cell_was_deleted.should != false
          end
        end
      end
    end
  end

  it "should call a method when the switch is flipped" do
    @controller.scroll_to_bottom
    tap "switch_1"
    wait 0.3 do
      @controller.tap_counter.should == 1
    end
  end

  it "should call the method with arguments when the switch is flipped and when the cell is tapped" do
    @controller.scroll_to_bottom
    tap "switch_3"
    wait 0.3 do
      @controller.tap_counter.should == 3

      tap "Switch With Cell Tap, Switch Action And Parameters"
      wait 0.3 do
        @controller.tap_counter.should == 13
      end
    end
  end

  it "should call the method with arguments when the switch is flipped" do
    @controller.scroll_to_bottom
    tap "switch_2"
    wait 0.3 do
      @controller.tap_counter.should == 3
    end
  end

end
