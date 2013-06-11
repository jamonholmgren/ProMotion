module ProMotion
  module MapScreenModule
    include ProMotion::ViewHelper
    include ScreenModule

    attr_accessor :map

    def map_setup
      # Create the Map
      set_up_start_position
    end

    def on_init
      self.map ||= add MKMapView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        resize: [ :width, :height ],
        delegate: self
      }
    end

    def set_start_position(params = {})
      ap params
      params[:latitude] ||= 37.331789
      params[:longitude] ||= -122.029620
      params[:radius] ||= 10

      meters_per_mile = 1609.344

      initialLocation = CLLocationCoordinate2D.new(params[:latitude], params[:longitude])
      region = MKCoordinateRegionMakeWithDistance(initialLocation, params[:radius] * meters_per_mile, params[:radius] * meters_per_mile)
      self.map.setRegion(region, animated:false)
    end

    def set_up_start_position
      if self.class.respond_to?(:get_start_position) && self.class.get_start_position
        self.set_start_position self.class.get_start_position_params
      end
    end

    module MapClassMethods
      def start_position(params={})
        @start_position_params = params
        @start_position = true
      end

      def get_start_position_params
        @start_position_params ||= nil
      end

      def get_start_position
        @start_position ||= false
      end
    end
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(MapClassMethods)
    end

  end
end
