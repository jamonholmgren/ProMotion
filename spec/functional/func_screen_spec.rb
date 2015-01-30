describe "ProMotion::Screen functionality" do
  tests PM::Screen

  before { UIView.setAnimationDuration 0.01 }

  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @controller = FunctionalScreen.new(nav_bar: true)
    @controller.navigationController
  end

  it "should call the on_back method on the root controller when navigating back" do
    presented_screen = PresentScreen.new
    @controller.open presented_screen, animated: false
    @controller.navigationController.viewControllers.should == [ @controller, presented_screen ]
    presented_screen.close animated: false
    @controller.on_back_fired.should == true
  end

  it "should call the correct on_back method when nesting screens" do
    child_screen = @controller.open NavigationScreen.new, animated: false
    grandchild_screen = child_screen.open NavigationScreen.new, animated: false

    # start closing
    grandchild_screen.close animated: false
    child_screen.on_back_fired.should == true
    child_screen.close animated: false
    @controller.on_back_fired.should == true
  end

  it "should fire the will_present, on_present, will_dismiss, and on_dismiss_methods" do
    @presented_screen = PresentScreen.new
    @controller.open @presented_screen, animated: false

    wait 0.01 do
      @presented_screen.will_present_fired.should == true
      @presented_screen.on_present_fired.should == true

      @presented_screen.will_dismiss_fired.should.not == true
      @presented_screen.on_dismiss_fired.should.not == true

      @presented_screen.reset
      @presented_screen.close animated: false

      wait 0.01 do
        @presented_screen.will_dismiss_fired.should == true
        @presented_screen.on_dismiss_fired.should == true

        @presented_screen.will_present_fired.should.not == true
        @presented_screen.on_present_fired.should.not == true

        @presented_screen = nil
      end
    end
  end

  it "should pop to the root view controller" do
    @root_vc = @controller.navigationController.visibleViewController
    @controller.navigationController.viewControllers.count.should == 1
    @controller.open BasicScreen.new, animated: false
    wait 0.01 do
      @controller.open BasicScreen.new, animated: false
      wait 0.01 do
        @controller.open BasicScreen.new, animated: false
        wait 0.01 do
          @controller.navigationController.viewControllers.count.should == 4
          @controller.close to_screen: :root, animated: false
          wait 0.01 do
            @controller.navigationController.viewControllers.count.should == 1
            @controller.navigationController.topViewController.should == @root_vc
          end
        end
      end
    end
  end
end
