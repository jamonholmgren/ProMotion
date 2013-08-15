describe "screen helpers" do

  describe "screen elements" do

    before do
      @screen = HomeScreen.new
      @screen.on_load
      @subview = UIView.alloc.initWithFrame CGRectZero
    end

    it "should add a subview" do
      @screen.add @subview
      @screen.view.subviews.count.should == 1
    end

    it "should set attributes before adding a subview" do
      @screen.add @subview, backgroundColor: UIColor.redColor
      @screen.view.subviews.first.backgroundColor.should == UIColor.redColor
    end

    it "should let you remove a view" do
      @screen.view.addSubview @subview
      @screen.remove @subview
      @screen.view.subviews.count.should == 0
    end

    it "should add a subview to another element" do
      sub_subview = UIView.alloc.initWithFrame CGRectZero
      @screen.add_to @subview, sub_subview
      @subview.subviews.include?(sub_subview).should == true
    end

    it "should add a subview to another element with attributes" do
      sub_subview = UIView.alloc.initWithFrame CGRectZero
      @screen.add_to @subview, sub_subview, { backgroundColor: UIColor.redColor }
      @subview.subviews.last.backgroundColor.should == UIColor.redColor
    end

  end

  describe "nav bar buttons" do

    before do
      @screen = HomeScreen.new(nav_bar: true)
    end


    [:left, :right, :back].each do |placement|
      buttonItemMethod = :"#{placement}BarButtonItem"

      it "should add a #{placement} nav bar button" do
        @screen.set_nav_bar_button placement, title: "Save", action: :save_something, type: UIBarButtonItemStyleDone
        @screen.navigationItem.send(buttonItemMethod).class.should == UIBarButtonItem
      end

      it "should add an image #{placement} nav bar button" do
        image = UIImage.imageNamed("list.png")
        @screen.set_nav_bar_button placement, image: image, action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
        @screen.navigationItem.send(buttonItemMethod).image.class.should == UIImage
        @screen.navigationItem.send(buttonItemMethod).image.should == image
      end

      it "should add a #{placement} UIBarButtonItem" do
        @screen.set_nav_bar_button placement, system_item: :add
        @screen.navigationItem.send(buttonItemMethod).class.should == UIBarButtonItem
      end

    end
  end

  describe "screen navigation" do

    before do
      @screen = HomeScreen.new nav_bar: true
      @screen.on_load
      @second_vc = UIViewController.alloc.initWithNibName(nil, bundle:nil)
    end

    it "#push_view_controller should use the default navigation controller if not provided" do
      vcs = @screen.navigation_controller.viewControllers
      @screen.push_view_controller @second_vc
      @screen.navigation_controller.viewControllers.count.should == vcs.count + 1
    end

    it "#push_view_controller should use a provided navigation controller" do
      second_nav_controller = UINavigationController.alloc.initWithRootViewController @screen
      @screen.push_view_controller @second_vc, second_nav_controller
      second_nav_controller.viewControllers.count.should == 2
    end

    it "should return the application delegate" do
      @screen.app_delegate.should == UIApplication.sharedApplication.delegate
    end



    describe "opening a screen" do

      it "should create an instance from class when opening a new screen" do
        @screen.send(:set_up_screen_for_open, BasicScreen).should.be.instance_of BasicScreen
      end

      it "should apply properties when opening a new screen" do
        new_screen = @screen.send(:set_up_screen_for_open, BasicScreen, title: 'Some Title', modal: true, hide_tab_bar: true, nav_bar: true)

        new_screen.parent_screen.should == @screen
        new_screen.title.should == 'Some Title'
        new_screen.modal?.should == true
        new_screen.hidesBottomBarWhenPushed.should == true
        new_screen.nav_bar?.should == true
      end

      it "should present the navigationController when showing a modal screen" do
        new_screen = @screen.send(:set_up_screen_for_open, BasicScreen, modal: true)

        @screen.mock!('presentModalViewController:animated:') do |vc, animated|
          vc.should == (new_screen.navigationController || new_screen)
          animated.should == true
        end
        @screen.send(:present_modal_view_controller, new_screen, true)
      end

      # it "should push screen onto nav controller stack inside a tab bar" do
      #   # TODO: Implement this test
      # end

      # it "should set the tab bar selectedIndex when opening a screen inside a tab bar" do
      #   # TODO: Implement this test
      # end

      it "should open a root screen if :close_all is provided" do
        @screen.mock!(:open_root_screen) { |screen| screen.should.be.instance_of BasicScreen }
        screen = @screen.open BasicScreen, close_all: true
        screen.should.be.kind_of BasicScreen
      end

      it "should present a modal screen if :modal is provided" do
        @screen.mock!(:present_modal_view_controller) do |screen, animated|
          screen.should.be.instance_of BasicScreen
          animated.should == true
        end
        screen = @screen.open BasicScreen, modal: true
        screen.should.be.kind_of BasicScreen
      end
      
      it "should present a modal screen if open_modal is used" do
        @screen.mock!(:present_modal_view_controller) do |screen, animated|
          screen.should.be.instance_of BasicScreen
          animated.should == true
        end
        screen = @screen.open_modal BasicScreen
        screen.should.be.kind_of BasicScreen
      end

      it "should respect animated property of opening modal screens" do
        new_screen = @screen.send(:set_up_screen_for_open, BasicScreen)

        @screen.mock!('presentModalViewController:animated:') do |vc, animated|
          animated.should == false
        end

        screen = @screen.send(:open, new_screen, animated: false, modal: true)
        screen.should.be.kind_of BasicScreen
      end

      it "should open screen in tab bar if :in_tab is provided" do
        @screen.stub!(:tab_bar, return: true)
        @screen.mock!(:present_view_controller_in_tab_bar_controller) do |screen, tab_name|
          screen.should.be.instance_of BasicScreen
          tab_name.should == 'my_tab'
        end
        screen = @screen.open BasicScreen, in_tab: 'my_tab'
        screen.should.be.kind_of BasicScreen
      end

      it "should pop onto navigation controller if current screen is on nav stack already" do
        @screen.mock!(:push_view_controller) { |vc| vc.should.be.instance_of BasicScreen }
        screen = @screen.open BasicScreen
        screen.should.be.kind_of BasicScreen
      end
      
      it "should ignore its own navigation controller if current screen has a navigation controller" do
        basic = BasicScreen.new(nav_bar: true) # creates a dangling nav_bar that will be discarded.
        screen = @screen.open basic
        screen.should.be.kind_of BasicScreen
        basic.navigationController.should == @screen.navigationController
        basic.navigation_controller.should == @screen.navigationController
        @screen.navigation_controller.should == @screen.navigationController
      end

      it "should open the provided view controller as root view if no other conditions are met" do
        parent_screen = HomeScreen.new
        new_screen = BasicScreen.new
        parent_screen.mock!(:open_root_screen) { |vc| vc.should.be == new_screen }
        screen = parent_screen.open_screen new_screen
        screen.should == new_screen
      end

    end


    describe "closing a screen" do

      before do
        @second_screen = BasicScreen.new
      end

      it "should close a modal screen" do
        parent_screen = HomeScreen.new
        @screen.parent_screen = parent_screen
        @screen.modal = true

        @screen.mock!(:close_modal_screen) { |args| args.should.be.instance_of Hash }
        @screen.close
      end

      it "#close_modal_screen should call #send_on_return" do
        parent_screen = HomeScreen.new
        @screen.parent_screen = parent_screen
        @screen.modal = true

        @screen.mock!(:send_on_return) { |args| args.should.be.instance_of Hash }
        parent_screen.mock!('dismissViewControllerAnimated:completion:') do |animated, completion|
          animated.should == true
          completion.should.be.instance_of Proc
          completion.call
        end
        @screen.close
      end

      it "should respect animated value for closing modal screens" do
        parent_screen = HomeScreen.new
        @screen.parent_screen = parent_screen
        @screen.modal = true

        parent_screen.mock!('dismissViewControllerAnimated:completion:') do |animated, completion|
          animated.should == false
        end

        @screen.send(:close, animated: false)
      end

      it "#close should pop from the navigation controller" do
        @screen.navigation_controller.mock!(:popViewControllerAnimated) { |animated| animated.should == true }
        @screen.close
      end

      it "#send_on_return shouldn't pass args to parent screen if there are none" do
        parent_screen = HomeScreen.new
        @screen.parent_screen = parent_screen

        parent_screen.mock!(:on_return) { |args| args.count.should == 0 }
        @screen.send_on_return
      end

      it "#send_on_return should pass args to parent screen" do
        parent_screen = HomeScreen.new
        @screen.parent_screen = parent_screen

        parent_screen.mock!(:on_return) { |args| args[:key].should == :value }
        @screen.send_on_return key: :value
      end

    end

  end

end
