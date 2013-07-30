describe "PM::TableViewCellModule" do

  def custom_cell
    {
      title: "Crazy Full Featured Cell",
      subtitle: "This is way too huge...",
      arguments: { data: [ "lots", "of", "data" ] },
      action: :tapped_cell_1,
      height: 50, # manually changes the cell's height
      cell_style: UITableViewCellStyleSubtitle,
      cell_identifier: "Custom Cell",
      cell_class: PM::TableViewCell,
      layer: { masks_to_bounds: true },
      background_color: UIColor.redColor,
      selection_style: UITableViewCellSelectionStyleGray,
      accessory:{view: :switch, value: true}, # currently only :switch is supported
      image: { image: UIImage.imageNamed("list"), radius: 15 },
      subviews: [ UIView.alloc.initWithFrame(CGRectZero), UILabel.alloc.initWithFrame(CGRectZero) ] # arbitrary views added to the cell
    }
  end

  def attributed_cell
    {
      title: NSMutableAttributedString.alloc.initWithString("Attributed Title"),
      subtitle: NSMutableAttributedString.alloc.initWithString("Attributed Subtitle"),
      cell_style: UITableViewCellStyleSubtitle
    }
  end

  before do
    @screen = TestTableScreen.new
    button = UIButton.buttonWithType(UIButtonTypeRoundedRect).tap{|b| b.titleLabel.text = "ACC" }
    @screen.mock! :table_data do
      [
        {
          title: "", cells: []
        },
        {
          title: "",
          cells: [
            { title: "Test 1", accessory_type: UITableViewCellStateShowingEditControlMask },
            custom_cell,
            { title: "Test2", accessory: { view: button } },
            attributed_cell
          ]
        }
      ]
    end

    @screen.on_load

    @custom_ip = NSIndexPath.indexPathForRow(1, inSection: 1) # Cell "Crazy Full Featured Cell"
    @attributed_ip = NSIndexPath.indexPathForRow(3, inSection: 1) # Attributed Cell

    @screen.update_table_data

    @subject = @screen.tableView(@screen.table_view, cellForRowAtIndexPath: @custom_ip)
    @attributed_subject = @screen.tableView(@screen.table_view, cellForRowAtIndexPath: @attributed_ip)
  end

  it "should be a PM::TableViewCell" do
    @subject.should.be.kind_of(PM::TableViewCell)
  end

  it "should have the right title" do
    @subject.textLabel.text.should == "Crazy Full Featured Cell"
  end

  it "should allow attributed title" do
    @attributed_subject.textLabel.attributedText.mutableString.should == "Attributed Title"
  end

  it "should allow attributed subtitle" do
    @attributed_subject.detailTextLabel.attributedText.mutableString.should == "Attributed Subtitle"
  end

  it "should have the right subtitle" do
    @subject.detailTextLabel.text.should == "This is way too huge..."
  end

  it "should have the right custom re-use identifier" do
    @subject.reuseIdentifier.should == "Custom Cell"
  end

  it "should have the right generated re-use identifier" do
    ip = NSIndexPath.indexPathForRow(2, inSection: 1)
    subject = @screen.tableView(@screen.table_view, cellForRowAtIndexPath: ip)
    subject.reuseIdentifier.should == "ProMotion::TableViewCell-accessory"
  end

  it "should have the correct height" do
    @screen.tableView(@screen.table_view, heightForRowAtIndexPath: @custom_ip).should == 50
  end

  it "should set the layer.masksToBounds" do
    @subject.layer.masksToBounds.should == true
  end

  it "should set the background color" do
    @subject.backgroundColor.should == UIColor.redColor
  end

  it "should set the selection color style" do
    @subject.selectionStyle.should == UITableViewCellSelectionStyleGray
  end

  it "should set the accessory view to a switch" do
    @subject.accessoryView.should.be.kind_of(UISwitch)
  end

  it "should set the accessory view to a button" do
    ip = NSIndexPath.indexPathForRow(2, inSection: 1)
    subject = @screen.tableView(@screen.table_view, cellForRowAtIndexPath: ip)
    subject.accessoryView.should.be.kind_of(UIRoundedRectButton)
  end

  it "should set the accessory type to edit" do
    ip = NSIndexPath.indexPathForRow(0, inSection: 1)
    subject = @screen.tableView(@screen.table_view, cellForRowAtIndexPath: ip)
    subject.accessoryView.should.be.nil
    subject.accessoryType.should == UITableViewCellStateShowingEditControlMask
  end

  it "should set an image with a radius" do
    @subject.imageView.should.be.kind_of(UIImageView)
    @subject.imageView.image.should == UIImage.imageNamed("list")
    @subject.imageView.layer.cornerRadius.should == 15.0
  end

  it "should create two extra subviews" do
    @subject.subviews.length.should == 3
    @subject.subviews[1].class.should == UIView
    @subject.subviews[2].class.should == UILabel
  end



end


