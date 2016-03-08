describe "Split screen functionality" do
  tests PM::SplitViewController

  # Override controller to properly instantiate
  def controller
    @app ||= TestDelegate.new
    @master = MasterScreen.new(nav_bar: true)
    @detail = DetailScreen.new(nav_bar: true)
    @controller ||= @app.create_split_screen @master, @detail, { button_title: "Test Title" }
  end

  before do
    UIView.setAnimationDuration 0.01
    UIView.setAnimationsEnabled false
    rotate_device to: :landscape, button: :right
  end

  after do
    rotate_device to: :portrait, button: :bottom
  end

  it "should allow opening a detail view from the master view" do

    @master.open BasicScreen.new(nav_bar: true), in_detail: true, animated: false

    view("Master").should.be.kind_of UINavigationItemView
    view("Basic").should.be.kind_of UINavigationItemView
    views(UINavigationItemView).each { |v| v.title.should.not == "Detail" }

  end

  it "should allow opening another view from the master view" do

    @master.open BasicScreen.new(nav_bar: true), animated: false

    view("Basic").should.be.kind_of UINavigationItemView
    view("Detail").should.be.kind_of UINavigationItemView

  end

  it "should allow opening a master view from the detail view" do

    @detail.open BasicScreen.new(nav_bar: true), in_master: true, animated: false

    view("Basic").should.be.kind_of UINavigationItemView
    view("Detail").should.be.kind_of UINavigationItemView
    views(UINavigationItemView).each { |v| v.title.should.not == "Master" }

  end

  it "should allow opening another view from the detail view" do

    @detail.open BasicScreen.new(nav_bar: true), animated: false

    view("Basic").should.be.kind_of UINavigationItemView
    view("Master").should.be.kind_of UINavigationItemView

  end

  unless ENV['TRAVIS'] # TODO: Why won't Travis pass these tests??
    it "should override the title on the button" do
      rotate_device to: :portrait, button: :bottom

      @detail.navigationItem.should.be.kind_of UINavigationItem
      @detail.navigationItem.leftBarButtonItem.should.be.kind_of UIBarButtonItem
      @detail.navigationItem.leftBarButtonItem.title.should == "Test Title"
    end

    it "should override the default swipe action, that reveals the menu" do
      rotate_device to: :portrait, button: :bottom

      @alt_controller = @app.open_split_screen @master, @detail, swipe: false, animated: false
      @app.home_screen.presentsWithGesture.should == false
    end
  end

end
