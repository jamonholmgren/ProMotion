module ProMotion
  # Instance methods
  class Screen
    attr_accessor :view_controller
    attr_accessor :navigation_controller
    
    def initialize(attrs = {})
      attrs.each do |k, v|
        self.call "#{k}=", v if self.respond_to? "#{k}="
      end
      
      self.view_controller = ViewController.alloc.initWithNibName(nil, bundle:nil)
    end
    
    def open(screen)
      # Instantiate screen if given a class instead
      screen = screen.new if screen.respond_to? :new
      
      # Push view onto existing UINavigationController
        
    end
  end
  
  # Class methods
  class Screen
    attr_accessor :x
    class << self
    end
  end
end