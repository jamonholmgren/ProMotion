describe "ProMotion::Screen functionality" do
  tests FunctionalScreen

  before { UIView.setAnimationDuration 0.01 }

  # Override controller to properly instantiate
  def screen
    @screen ||= FunctionalScreen.new
  end

  def controller
    screen.navigationController
  end

  before { rotate_device to: :portrait, button: :bottom }
  after { @screen = nil }

  it "should call the on_back method on the root controller when navigating back" do
    presented_screen = PresentScreen.new
    screen.open presented_screen, animated: false
    screen.navigationController.viewControllers.should == [ screen, presented_screen ]
    presented_screen.close animated: false
    screen.on_back_fired.should == true
  end

  it "should call the correct on_back method when nesting screens" do
    child_screen = screen.open NavigationScreen.new, animated: false
    grandchild_screen = child_screen.open NavigationScreen.new, animated: false

    # start closing
    grandchild_screen.close animated: false
    child_screen.on_back_fired.should == true
    child_screen.close animated: false
    screen.on_back_fired.should == true
  end

  it "should fire the will_present, on_present, will_dismiss, and on_dismiss_methods" do
    @presented_screen = PresentScreen.new
    screen.open @presented_screen, animated: false

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

  it "should pop to the root view screen" do
    @root_vc = screen.navigationController.visibleViewController
    screen.navigationController.viewControllers.count.should == 1
    screen.open BasicScreen.new, animated: false
    wait 0.01 do
      screen.open BasicScreen.new, animated: false
      wait 0.01 do
        screen.open BasicScreen.new, animated: false
        wait 0.01 do
          screen.navigationController.viewControllers.count.should == 4
          screen.close to_screen: :root, animated: false
          wait 0.01 do
            screen.navigationController.viewControllers.count.should == 1
            screen.navigationController.topViewController.should == @root_vc
          end
        end
      end
    end
  end
end
