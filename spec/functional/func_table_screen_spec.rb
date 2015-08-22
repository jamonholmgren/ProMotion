describe "ProMotion::TableScreen functionality" do
  tests PM::TestTableScreen

  def table_screen
    @table_screen ||= TestTableScreen.new(nav_bar: true)
  end

  def controller
    # rotate_device to: :portrait, button: :bottom
    table_screen.navigationController
  end

  def confirmation_class
    TestHelper.ios7 ? "UITableViewCellDeleteConfirmationButton" : "UITableViewCellDeleteConfirmationControl"
  end

  def table_label_class
    TestHelper.ios7 ? "UILabel" : "UITableViewLabel"
  end

  after { @table_screen = nil }

  it "should have a navigation bar" do
    table_screen.navigationController.should.be.kind_of(UINavigationController)
  end

  unless ENV['TRAVIS']
    it "should increment the tap counter on tap" do
      tap("Increment")
      table_screen.tap_counter.should == 3
    end

    it "should add a new table cell on tap" do
      tap("Add New Row")
      view("Dynamically Added").class.to_s.should == table_label_class
    end

    it "should do nothing when no action specified" do
      tap("Just another blank row")
      table_screen.should == table_screen
    end

    it "should increment the tap counter by one on tap" do
      tap("Increment One")
      table_screen.tap_counter.should == 1
    end

    it "should delete the specified row from the table view on tap" do
      table_screen.tableView(table_screen.tableView, numberOfRowsInSection:0).should == 7
      tap("Delete the row below")
      wait 0.01 do
        table_screen.tableView(table_screen.tableView, numberOfRowsInSection:0).should == 6
      end
    end

    it "should delete the specified row from the table view on tap with an animation" do
      table_screen.tableView(table_screen.tableView, numberOfRowsInSection:0).should == 7
      tap("Delete the row below with an animation")
      wait 0.01 do
        table_screen.tableView(table_screen.tableView, numberOfRowsInSection:0).should == 6
      end
    end

    # TODO: Why is it so complicated to find the delete button??
    it "should use editing_style to delete the table row" do
      table_screen.tableView(table_screen.tableView, numberOfRowsInSection:0).should == 7
      table_screen.cell_was_deleted.should != true
      flick("Just another deletable blank row", to: :left)

      wait 0.01 do
        # Tap the delete button
        view('Just another deletable blank row').superview.superview.subviews.each do |subview|
          if subview.class.to_s == confirmation_class
            tap subview
            wait 0.01 do
              table_screen.tableView(table_screen.tableView, numberOfRowsInSection:0).should == 6
              table_screen.cell_was_deleted.should == true
              table_screen.cell_deleted_index_path.should == NSIndexPath.indexPathForRow(3, inSection:0)
            end
          end
        end
      end
    end

    it "should not allow deleting if on_cell_delete returns `false`" do
      table_screen.tableView(table_screen.tableView, numberOfRowsInSection:0).should == 7
      table_screen.cell_was_deleted.should != true
      flick("A non-deletable blank row", to: :left)

      wait 0.01 do
        # Tap the delete button
        view('A non-deletable blank row').superview.superview.subviews.each do |subview|
          if subview.class == confirmation_class
            tap subview
            wait 0.01 do
              table_screen.tableView(table_screen.tableView, numberOfRowsInSection:0).should == 7
              table_screen.cell_was_deleted.should != false
            end
          end
        end
      end
    end
  end

  it "should not crash if cell with editing_style is swiped left" do
    Proc.new { flick("Just another deletable blank row", to: :left) }.should.not.raise(StandardError)
  end

  it "should not crash if cell with no editing_style is swiped left" do
    Proc.new { flick("Increment", to: :left) }.should.not.raise(StandardError)
  end

end
