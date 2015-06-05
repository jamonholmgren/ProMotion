module ProMotion
  module ScreenNavigation
    include ProMotion::Support

    def open_screen(screen, args = {})
      args = { animated: true }.merge(args)

      # Apply properties to instance
      screen = set_up_screen_for_open(screen, args)
      ensure_wrapper_controller_in_place(screen, args)

      opened ||= open_in_split_screen(screen, args) if self.split_screen
      opened ||= open_root_screen(screen) if args[:close_all]
      opened ||= present_modal_view_controller(screen, args) if args[:modal]
      opened ||= open_in_tab(screen, args[:in_tab]) if args[:in_tab]
      opened ||= push_view_controller(screen, self.navigationController, !!args[:animated]) if self.navigationController
      opened ||= open_root_screen(screen.navigationController || screen)
      screen
    end
    alias :open :open_screen

    def open_in_split_screen(screen, args)
      self.split_screen.detail_screen = screen if args[:in_detail]
      self.split_screen.master_screen = screen if args[:in_master]
      args[:in_detail] || args[:in_master]
    end

    def open_root_screen(screen)
      app_delegate.open_root_screen(screen)
    end

    def open_modal(screen, args = {})
      open screen, args.merge({ modal: true })
    end

    def close_screen(args = {})
      args ||= {}
      args = { sender: args } unless args.is_a?(Hash)
      args[:animated] = true unless args.has_key?(:animated)

      if self.modal?
        close_nav_screen args if self.navigationController
        close_modal_screen args

      elsif self.navigationController
        close_nav_screen args
        send_on_return(args)

      else
        mp "Tried to close #{self.to_s}; however, this screen isn't modal or in a nav bar.", force_color: :yellow
      end
    end
    alias :close :close_screen

    def send_on_return(args = {})
      return unless self.parent_screen
      if self.parent_screen.respond_to?(:on_return)
        if args && self.parent_screen.method(:on_return).arity != 0
          self.parent_screen.send(:on_return, args)
        else
          self.parent_screen.send(:on_return)
        end
      elsif self.parent_screen.private_methods.include?(:on_return)
        mp "#{self.parent_screen.inspect} has an `on_return` method, but it is private and not callable from the closing screen.", force_color: :yellow
      end
    end

    def push_view_controller(vc, nav_controller=nil, animated=true)
      unless self.navigationController
        mp "You need a nav_bar if you are going to push #{vc.to_s} onto it.", force_color: :red
      end
      nav_controller ||= self.navigationController
      return if nav_controller.topViewController == vc
      vc.first_screen = false if vc.respond_to?(:first_screen=)
      nav_controller.pushViewController(vc, animated: animated)
    end

  protected

    def set_up_screen_for_open(screen, args={})

      # Instantiate screen if given a class
      screen = screen.new if screen.respond_to?(:new)

      # Store screen options
      screen.instance_variable_set(:@screen_options, args)

      # Set parent
      screen.parent_screen = self if screen.respond_to?(:parent_screen=)

      # Set title & modal properties
      screen.title = args[:title] if args[:title] && screen.respond_to?(:title=)
      screen.modal = args[:modal] if args[:modal] && screen.respond_to?(:modal=)

      # Hide bottom bar?
      screen.hidesBottomBarWhenPushed = args[:hide_tab_bar] == true

      # Wrap in a PM::NavigationController?
      screen.add_nav_bar(args) if args[:nav_bar] && screen.respond_to?(:add_nav_bar)

      # Return modified screen instance
      screen

    end

    def ensure_wrapper_controller_in_place(screen, args={})
      unless args[:close_all] || args[:modal] || args[:in_detail] || args[:in_master]
        screen.navigationController ||= self.navigationController if screen.respond_to?("navigationController=")
        screen.tab_bar ||= self.tab_bar if screen.respond_to?("tab_bar=")
      end
    end

    def present_modal_view_controller(screen, args={})
      self.presentViewController((screen.navigationController || screen), animated: args[:animated], completion: args[:completion])
    end

    def open_in_tab(screen, tab_name)
      vc = open_tab(tab_name)
      return mp("No tab bar item '#{tab_name}'", force_color: :red) && nil unless vc
      if vc.is_a?(UINavigationController)
        push_view_controller(screen, vc)
      else
        replace_view_controller(screen, vc)
      end
    end

    def replace_view_controller(new_vc, old_vc)
      self.tab_bar.viewControllers = self.tab_bar.viewControllers.map do |vc|
        vc == old_vc ? new_vc : vc
      end
    end

    def close_modal_screen(args={})
      args[:animated] = true unless args.has_key?(:animated)
      self.parent_screen.dismissViewControllerAnimated(args[:animated], completion: lambda {
        send_on_return(args)
      })
    end

    def close_nav_screen(args={})
      args[:animated] = true unless args.has_key?(:animated)
      if args[:to_screen] == :root
        self.parent_screen = self.navigationController.viewControllers.first
        self.navigationController.popToRootViewControllerAnimated args[:animated]
      elsif args[:to_screen] && args[:to_screen].is_a?(UIViewController)
        self.parent_screen = args[:to_screen]
        self.navigationController.popToViewController(args[:to_screen], animated: args[:animated])
      else
        self.navigationController.popViewControllerAnimated(args[:animated])
      end
      self.navigationController = nil
    end

  end
end
