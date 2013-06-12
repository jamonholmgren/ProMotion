class MapScreenAnnotation

  #Creates the new crime object
  def initialize(params = {})
    @params = params
    set_defaults

    unless @params[:latitude] && @params[:longitude]
      PM.logger.error("You are required to specify :latitude and :longitude for annotations.")
      return nil
    end
    @coordinate = CLLocationCoordinate2DMake(@params[:latitude], @params[:longitude])
  end

  def set_defaults
    @params[:title] ||= "Title"
    @params[:subtitle] ||= "Subtitle"
    @params[:pin_color] ||= MKPinAnnotationColorRed
    @params[:identifier] ||= "Annotation-#{pin_color}"
    @params[:show_callout] ||= true
    @params[:animates_drop] ||= false
  end

  def title
    @params[:title]
  end

  def subtitle
    @params[:subtitle]
  end

  def coordinate
    @coordinate
  end

  def cllocation
    CLLocation.alloc.initWithLatitude(@params[:latitude], longitude:@params[:longitude])
  end

  def setCoordinate(new_coordinate);
    if new_coordinate.is_a? Hash
      @coordinate = CLLocationCoordinate2DMake(new_coordinate[:latitude], new_coordinate[:longitude])
    else
      @coordinate = new_coordinate
    end
  end

  # These methods are used to hold the data from the original annotation hash
  # and are applied to the MKAnnotationView later on in the view cycle.
  def identifier
    @params[:identifier]
  end

  def pin_color
    @params[:pin_color]
  end

  def show_callout
    @params[:show_callout]
  end

  def animates_drop
    @params[:animates_drop]
  end

  # Allows for retrieving your own custom values on the annotation
  def annotation_params
    @params
  end

end
