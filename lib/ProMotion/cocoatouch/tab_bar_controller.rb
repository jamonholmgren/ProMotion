module ProMotion
  class TabBarController < UITabBarController

    attr_accessor :pm_tab_delegate

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
      tab_bar_controller.delegate = tab_bar_controller
      tab_bar_controller
    end

    def open_tab(tab)
      if tab.is_a? String
        selected_tab_vc = find_tab(tab)
      elsif tab.is_a? Numeric
        selected_tab_vc = viewControllers[tab]
      end

      if selected_tab_vc
        self.selectedViewController = selected_tab_vc
        on_tab_selected_try(selected_tab_vc)

        selected_tab_vc
      else
        PM.logger.error "Unable to open tab #{tab.to_s} -- not found."
        nil
      end
    end

    def find_tab(tab_title)
      viewControllers.find { |vc| vc.tabBarItem.title == tab_title }
    end

    # Cocoa touch methods below
    def tabBarController(tbc, didSelectViewController: vc)
      on_tab_selected_try(vc)
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

    def on_tab_selected_try(vc)
      if pm_tab_delegate && pm_tab_delegate.respond_to?("on_tab_selected:")
        pm_tab_delegate.send(:on_tab_selected, vc)
      end
    end

    def current_view_controller
      selectedViewController || viewControllers.first
    end

    def current_view_controller_try(method, *args)
      current_view_controller.send(method, *args) if current_view_controller.respond_to?(method)
    end

  end
end
