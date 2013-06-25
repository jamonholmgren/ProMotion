describe "ProMotion::Screen functional" do
  tests PM::Screen

  # Override controller to properly instantiate
  def controller
    rotate_device to: :portrait, button: :bottom
    @controller ||= FunctionalScreen.new(nav_bar: true)
    @controller.navigation_controller
  end

  after do
    @controller = nil
  end

  it "should have a navigation bar" do
    view("Functional").should.be.kind_of UINavigationItemView
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

end
