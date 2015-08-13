describe "collection screens" do
  tests TestCollectionScreen

  def screen
    @screen ||= TestCollectionScreen.new(nav_bar: true)
  end

  def controller
    screen.navigationController
  end

  describe "basic functionality" do

    before do
      @screen = TestCollectionScreen.new(nav_bar: true)
      @view = @screen.collection_view
    end

    after do
      @screen = nil
    end

    it "should display some sections" do
      @screen.promotion_collection_data.sections.should.be.kind_of(Array)
    end

    it "should have the proper number of sections" do
      @view.numberOfSections.should == 11
      @screen.numberOfSectionsInCollectionView(@view).should == 11
    end

    it "should have the proper number of cells" do
      @view.numberOfItemsInSection(1).should == 10
      @screen.collectionView(@view, numberOfItemsInSection: 1).should == 10
    end

    it "should call the action" do
      @screen.mock! :touched do |args|
        args[:data].should == ['action']
      end

      index_path = NSIndexPath.indexPathForRow(1, inSection: 1)
      @screen.collectionView(@view, didSelectItemAtIndexPath: index_path)
    end

    it "should proc the action" do
      @screen.mock! :touched do |args|
        args[:data].should == ['proc']
      end

      index_path = NSIndexPath.indexPathForRow(1, inSection: 10)
      @screen.collectionView(@view, didSelectItemAtIndexPath: index_path)
    end

    it "should reload data" do
      data = (1..2).to_a.map do |i|
        (1..3).to_a.map do |o|
          {
              cell_identifier:  :custom_cell,
              title:            "#{i}x#{o}",
              action:           'touched:',
              background_color: UIColor.colorWithRed(rand(255) / 255.0,
                                                     green: rand(255) / 255.0,
                                                     blue:  rand(255) / 255.0,
                                                     alpha: 1.0)
          }
        end
      end
      @screen.update_collection_view_data(data)
      @view.numberOfSections.should == 2
      @view.numberOfItemsInSection(1).should == 3
    end

  end

  describe "layout functionality" do
    before do
      @screen = TestCollectionScreen.new
      @view = @screen.collection_view
      @layout = @screen.collectionViewLayout
    end

    after do
      @screen = nil
    end

    it "layout should have correct sizes" do
      @layout.estimatedItemSize.should == CGSizeMake(80, 80) if TestHelper.gte_ios8
      @layout.itemSize.should == CGSizeMake(100, 80)
    end

    it "layout should be :horizontal" do
      @layout.scrollDirection.should == UICollectionViewScrollDirectionHorizontal
    end

    it "layout should have a correct sectionInset" do
      @layout.sectionInset.should == UIEdgeInsetsMake(10, 10, 10, 10)
    end

  end

  describe "cells" do
    before do
      @screen = TestCollectionScreen.new
      @view = @screen.collection_view
    end

    after do
      @screen = nil
    end

    it "should be CustomCollectionViewCell cells" do
      index_path = NSIndexPath.indexPathForRow(1, inSection: 1)

      @screen.collectionView(@view, cellForItemAtIndexPath: index_path).should.be.kind_of CustomCollectionViewCell
    end

    it "should have a correct size" do
      index_path = NSIndexPath.indexPathForRow(1, inSection: 1)

      cell = @screen.collectionView(@view, cellForItemAtIndexPath: index_path)
      cell.should.not == nil
      cell.frame.size.should == CGSizeMake(100, 80)
    end

    it "should get properties" do
      data = @screen.cell_at(section: 1, index: 1)
      data[:background_color].should.be.kind_of UIColor
    end

  end

end
