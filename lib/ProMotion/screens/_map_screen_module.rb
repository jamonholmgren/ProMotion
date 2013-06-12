module ProMotion
  module MapScreenModule
    include ProMotion::ViewHelper
    include ScreenModule

    attr_accessor :mapview

    def map_setup
      # Create the Map
      @annotations ||= []
      set_up_start_position
    end

    def on_init
      self.mapview ||= add MKMapView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        resize: [ :width, :height ],
        delegate: self
      }
    end

    def map
      self.mapview
    end

    def annotations
      @annotations
    end

    def add_annotation(annotation)
      @annotations << MapScreenAnnotation.new(annotation)
      self.mapview.addAnnotation @annotations.last
    end

    def clear_annotations
      @annotations.each do |a|
        self.mapview.removeAnnotation(a)
      end
      @annotations = []
    end

    def mapView(mapView, viewForAnnotation:annotation)
      identifier = annotation.identifier
      if view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        view.annotation = annotation
      else
        #Set the pin properties
        view = MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
        view.canShowCallout = annotation.show_callout
        view.animatesDrop = annotation.animates_drop
        view.pinColor = annotation.pin_color
      end
      view
    end

    def set_start_position(params = {})
      params[:latitude] ||= 37.331789
      params[:longitude] ||= -122.029620
      params[:radius] ||= 10

      meters_per_mile = 1609.344

      initialLocation = CLLocationCoordinate2D.new(params[:latitude], params[:longitude])
      region = MKCoordinateRegionMakeWithDistance(initialLocation, params[:radius] * meters_per_mile, params[:radius] * meters_per_mile)
      self.mapview.setRegion(region, animated:false)
    end

    def set_up_start_position
      if self.class.respond_to?(:get_start_position) && self.class.get_start_position
        self.set_start_position self.class.get_start_position_params
      end
    end

    def something
      return if annotations.count == 0

      annotation_pad = 1.15
      max_degrees = 360
      minimum_zoom 0.014 # Approximately 1 miles (1 degree of arc ~= 69 miles)

      points = []
      annotations.each do |a|
        points << MKMapPointForCoordinate(a.coordinate);
      end

      mapRect = MKPolygon.polygonWithPoints(points, count:points.count).boundingMapRect
      region = MKCoordinateRegionForMapRect(mapRect)

      #add padding so pins aren't scrunched on the edges
      region.span.latitudeDelta  *= annotation_pad
      region.span.longitudeDelta *= annotation_pad

      # but padding can't be bigger than the world
      region.span.latitudeDelta  = max_degrees if region.span.latitudeDelta > max_degrees
      region.span.longitudeDelta = max_degrees if region.span.longitudeDelta > max_degrees

      # And don't zoom in stupid-close on small samples
      region.span.latitudeDelta  = minimum_zoom if region.span.latitudeDelta  < minimum_zoom
      region.span.longitudeDelta = minimum_zoom if region.span.longitudeDelta < minimum_zoom

      # If there is a sample of 1 we want the max zoom-in instead of max zoom-out
      if points.count == 1
        region.span.latitudeDelta = minimum_zoom;
        region.span.longitudeDelta = minimum_zoom;
      end

    end

    def zoom_to_fit_annotations(animated = true)
      #Don't attempt the rezoom of there are no pins
      return if annotations.count == 0

      #Set some crazy boundaries
      topLeft = CLLocationCoordinate2DMake(-90, 180)
      bottomRight = CLLocationCoordinate2DMake(90, -180)

      #Find the bounds of the pins
      annotations.each do |a|
        topLeft.longitude = [topLeft.longitude, a.coordinate.longitude].min
        topLeft.latitude = [topLeft.latitude, a.coordinate.latitude].max
        bottomRight.longitude = [bottomRight.longitude, a.coordinate.longitude].max
        bottomRight.latitude = [bottomRight.latitude, a.coordinate.latitude].min
      end

      #Find the bounds of all the pins and set the mapView
      coord = CLLocationCoordinate2DMake(
        topLeft.latitude - (topLeft.latitude - bottomRight.latitude) * 0.5,
        topLeft.longitude + (bottomRight.longitude - topLeft.longitude) * 0.5
      )

      # Add some padding to the edges
      span = MKCoordinateSpanMake(
        ((topLeft.latitude - bottomRight.latitude) * 1.075).abs,
        ((bottomRight.longitude - topLeft.longitude) * 1.075).abs
      )

      region = MKCoordinateRegionMake(coord, span)
      fits = self.mapview.regionThatFits(region);

      self.mapview.setRegion(fits, animated:animated)
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
