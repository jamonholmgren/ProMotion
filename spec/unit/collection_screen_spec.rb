describe "collection screens" do

  describe "basic functionality" do

    before do
      @screen = TestCollectionScreen.new
    end

    it "should display some sections" do
      @screen.promotion_collection_data.sections.should.be.kind_of(Array)
    end

  end

end
