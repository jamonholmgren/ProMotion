module ProMotion
  class NavigationController < UINavigationController
    def dealloc
      $stderr.puts "Deallocating #{self.to_s}"
    end
  end
end