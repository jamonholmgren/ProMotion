module ProMotion
  class NavigationController < UINavigationController
    def dealloc
      $stderr.puts "Deallocating #{self.to_s}" if ProMotion::Screen.debug_mode
    end
  end
end