module ProMotion
  class TabBarController < UITabBarController
    attr_accessor :pm_tab_delegate, :name

    def self.new(*screens)
      tab_bar_controller = alloc.init

      screens = screens.flatten.map { |s| s.respond_to?(:new) ? s.new : s } # Initialize any classes

      tag_index = 0
      view_controllers = screens.map do |s|
        s.tabBarItem.tag = tag_index
        s.tab_bar = WeakRef.new(tab_bar_controller) if s.respond_to?("tab_bar=")
        tag_index += 1
        s.navigationController || s
      end

      tab_bar_controller.viewControllers = view_controllers
      name = ""
      tab_bar_controller.delegate = tab_bar_controller
      tab_bar_controller
    end

    def name=(n)
      @name = n
      tab_bar_order = NSUserDefaults.standardUserDefaults.arrayForKey("tab_bar_order_#{@name}")
      if tab_bar_order
        sorted_controllers = []
        unsorted_controllers = self.viewControllers.copy
        tab_bar_order.each do |order|
          sorted_controllers << unsorted_controllers[order]
        end
        self.viewControllers = sorted_controllers
        open_tab(0) # Open the tab on the far left
      end
    end

    def open_tab(tab)
      if tab.is_a? String
        selected_tab_vc = find_tab(tab)
      elsif tab.is_a? Numeric
        selected_tab_vc = viewControllers[tab]
      end

      unless selected_tab_vc
        mp "Unable to open tab #{tab} -- not found.", force_color: :red
        return
      end

      return unless should_select_tab_try(selected_tab_vc)

      self.selectedViewController = selected_tab_vc
      on_tab_selected_try(selected_tab_vc)

      selected_tab_vc
    end

    def find_tab(tab_title)
      viewControllers.find { |vc| vc.tabBarItem.title == tab_title }
    end

    # Cocoa touch methods below
    def tabBarController(tbc, shouldSelectViewController: vc)
      should_select_tab_try(vc)
    end

    def tabBarController(tbc, didSelectViewController: vc)
      on_tab_selected_try(vc)
    end

    def tabBarController(tbc, didEndCustomizingViewControllers:vcs, changed:changed)
      if changed
        tab_order = vcs.map { |vc| vc.tabBarItem.tag }
        NSUserDefaults.standardUserDefaults.setObject(tab_order, forKey:"tab_bar_order_#{@name}")
        NSUserDefaults.standardUserDefaults.synchronize
      end
    end

    def shouldAutorotate
      current_view_controller_try(:shouldAutorotate)
    end

    def supportedInterfaceOrientations
      current_view_controller_try(:supportedInterfaceOrientations)
    end

    def preferredInterfaceOrientationForPresentation
      current_view_controller_try(:preferredInterfaceOrientationForPresentation)
    end

    private

    # Defaults to true if :should_select_tab tab is not implemented by the tab delegate.
    def should_select_tab_try(vc)
      method_name = :should_select_tab
      return true unless can_send_method_to_delegate?(method_name)

      pm_tab_delegate.send(method_name, vc)
    end

    def on_tab_selected_try(vc)
      method_name = :on_tab_selected
      return unless can_send_method_to_delegate?(method_name)

      pm_tab_delegate.send(method_name, vc)
    end

    def current_view_controller
      selectedViewController || viewControllers.first
    end

    def current_view_controller_try(method, *args)
      return unless current_view_controller.respond_to?(method)

      current_view_controller.send(method, *args)
    end

    def can_send_method_to_delegate?(method)
      pm_tab_delegate &&
        pm_tab_delegate.respond_to?(:weakref_alive?) &&
        pm_tab_delegate.weakref_alive? &&
        pm_tab_delegate.respond_to?("#{method}:")
    end
  end
end
