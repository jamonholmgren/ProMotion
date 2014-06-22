describe "ProMotion::Screen functional" do
  tests PM::Screen

  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @controller = FunctionalScreen.new(nav_bar: true)
    @controller.navigationController
  end

  it "should have a navigation bar" do
    wait 0.5 do
      view("Functional").should.be.kind_of UINavigationItemView
    end
  end

  it "should allow a string title" do
    views(UINavigationItemView).include?(UIImageView).should.not.be.true
  end

  it "should allow setting a left nav bar button" do
    @controller.set_nav_bar_button :left, title: "Cool", action: :triggered_button
    tap("Cool")
    @controller.button_was_triggered.should.be.true
  end

  it "should allow setting a right nav bar button" do
    @controller.set_nav_bar_button :right, title: "Cool2", action: :triggered_button
    tap("Cool2")
    @controller.button_was_triggered.should.be.true
  end

  it "should allow opening another screen in the same nav bar and have a back button that is operational" do
    @controller.open BasicScreen

    wait 0.5 do

      view("Basic").should.be.kind_of UINavigationItemView
      view("Functional").should.be.kind_of UINavigationItemButtonView

      tap("Functional")
      wait 0.5 do
        view("Functional").should.be.kind_of UINavigationItemView
      end

    end
    
  end

  it "should push another screen with animation by default" do
    basic = @controller.open BasicScreen
    wait 0.5 do
      basic.animation_ts.should.be > 0.2
    end
  end

  it "should push another screen with animation when animated: true" do
    basic = @controller.open BasicScreen, animated: true
    wait 0.5 do
      basic.animation_ts.should.be > 0.2
    end
  end

  it "should push another screen without animation when animated: false" do
    basic = @controller.open BasicScreen, animated: false
    wait 0.5 do
      basic.animation_ts.should.be < 0.2
    end
  end


  it "should allow opening and closing a modal screen" do
    @basic = BasicScreen.new(nav_bar: true)
    wait 0.1 do
      @controller.open_modal @basic

      wait 0.6 do

        view("Basic").should.be.kind_of UINavigationItemView
        @basic.close

        wait 0.6 do
          @basic = nil
          view("Functional").should.be.kind_of UINavigationItemView
        end

      end
    end
  end

  it "should fire the will_present, on_present, will_dismiss, and on_dismiss_methods" do
    @presented_screen = PresentScreen.new
    @controller.open @presented_screen
    wait 0.6 do
      @presented_screen.will_present_fired.should == true
      @presented_screen.on_present_fired.should == true

      @presented_screen.will_dismiss_fired.should.not == true
      @presented_screen.on_dismiss_fired.should.not == true

      @presented_screen.reset

      @presented_screen.close
      wait 0.6 do
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
    @controller.open BasicScreen.new
    wait 0.6 do
      @controller.open BasicScreen.new
      wait 0.6 do
        @controller.open BasicScreen.new
        wait 0.6 do
          @controller.navigationController.viewControllers.count.should == 4
          @controller.close to_screen: :root
          wait 0.6 do
            @controller.navigationController.viewControllers.count.should == 1
            @controller.navigationController.topViewController.should == @root_vc
          end
        end
      end
    end
  end

end
