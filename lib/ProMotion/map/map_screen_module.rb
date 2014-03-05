module ProMotion
  module MapScreenModule
    attr_accessor :mapview

    def screen_setup
      check_mapkit_included
      self.mapview ||= add MKMapView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        resize: [ :width, :height ],
        delegate: self
      }

      check_annotation_data
      @promotion_annotation_data = []
      set_up_start_position
    end

    def view_will_appear(animated)
      super
      update_annotation_data
    end

    def check_mapkit_included
      PM.logger.error "You must add MapKit and CoreLocation to your project's frameworks in the Rakefile." unless defined?(CLLocationCoordinate2D)
    end

    def check_annotation_data
      PM.logger.error "Missing #annotation_data method in MapScreen #{self.class.to_s}." unless self.respond_to?(:annotation_data)
    end

    def update_annotation_data
      clear_annotations
      add_annotations annotation_data
    end

    def map
      self.mapview
    end

    def center
      self.mapview.centerCoordinate
    end

    def center=(params={})
      PM.logger.error "Missing #:latitude property in call to #center=." unless params[:latitude]
      PM.logger.error "Missing #:longitude property in call to #center=." unless params[:longitude]
      params[:animated] = true

      # Set the new region
      self.mapview.setCenterCoordinate(
        CLLocationCoordinate2D.new(params[:latitude], params[:longitude]),
        animated:params[:animated]
      )
    end

    def annotations
      @promotion_annotation_data
    end

    def select_annotation(annotation, animated=true)
      self.mapview.selectAnnotation(annotation, animated:animated)
    end

    def select_annotation_at(annotation_index, animated=true)
      select_annotation(annotations[annotation_index], animated:animated)
    end

    def selected_annotations
      self.mapview.selectedAnnotations
    end

    def deselect_annotations(animated=false)
      unless selected_annotations.nil?
        selected_annotations.each do |annotation|
          self.mapview.deselectAnnotation(annotation, animated:animated)
        end
      end
    end

    def add_annotation(annotation)
      @promotion_annotation_data << MapScreenAnnotation.new(annotation)
      self.mapview.addAnnotation @promotion_annotation_data.last
    end

    def add_annotations(annotations)
      @promotion_annotation_data = Array(annotations).map{|a| MapScreenAnnotation.new(a)}
      self.mapview.addAnnotations @promotion_annotation_data
    end

    def clear_annotations
      @promotion_annotation_data.each do |a|
        self.mapview.removeAnnotation(a)
      end
      @promotion_annotation_data = []
    end

    def mapView(mapView, viewForAnnotation:annotation)
      identifier = annotation.annotation_params[:identifier]
      if view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        view.annotation = annotation
      else
        #Set the pin properties
        if annotation.annotation_params[:image]
          view = MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
          view.image =  annotation.annotation_params[:image]
        else
          view = MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
          view.animatesDrop = annotation.annotation_params[:animates_drop]
          view.pinColor = annotation.annotation_params[:pin_color]
        end
        view.canShowCallout = annotation.annotation_params[:show_callout]
      end
      view
    end

    def set_start_position(params={})
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

    # TODO: Why is this so complex?
    def zoom_to_fit_annotations(animated=true)
      #Don't attempt the rezoom of there are no pins
      return if annotations.count == 0

      #Set some crazy boundaries
      topLeft = CLLocationCoordinate2D.new(-90, 180)
      bottomRight = CLLocationCoordinate2D.new(90, -180)

      #Find the bounds of the pins
      annotations.each do |a|
        topLeft.longitude = [topLeft.longitude, a.coordinate.longitude].min
        topLeft.latitude = [topLeft.latitude, a.coordinate.latitude].max
        bottomRight.longitude = [bottomRight.longitude, a.coordinate.longitude].max
        bottomRight.latitude = [bottomRight.latitude, a.coordinate.latitude].min
      end

      #Find the bounds of all the pins and set the mapView
      coord = CLLocationCoordinate2D.new(
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

    def set_region(region, animated=true)
      self.mapview.setRegion(region, animated:animated)
    end

    def region(params)
      return nil unless params.is_a? Hash

      params[:coordinate] = CLLocationCoordinate2D.new(params[:coordinate][:latitude], params[:coordinate][:longitude]) if params[:coordinate].is_a? Hash
      params[:span] = MKCoordinateSpanMake(params[:span][0], params[:span][1]) if params[:span].is_a? Array

      if params[:coordinate] && params[:span]
        MKCoordinateRegionMake( params[:coordinate], params[:span] )
      end
    end

    def look_up_address(args={}, &callback)
      args[:address] = args if args.is_a? String # Assume if a string is passed that they want an address

      geocoder = CLGeocoder.new
      return geocoder.geocodeAddressDictionary(args[:address], completionHandler: callback) if args[:address].is_a?(Hash)
      return geocoder.geocodeAddressString(args[:address].to_s, completionHandler: callback) unless args[:region]
      return geocoder.geocodeAddressString(args[:address].to_s, inRegion:args[:region].to_s, completionHandler: callback) if args[:region]
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
      base.extend(MapClassMethods)
    end

  end
end
