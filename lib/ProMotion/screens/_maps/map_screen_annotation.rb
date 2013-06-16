class MapScreenAnnotation

  #Creates the new crime object
  def initialize(params = {})
    @params = params
    set_defaults

    unless @params[:latitude] && @params[:longitude]
      PM.logger.error("You are required to specify :latitude and :longitude for annotations.")
      return nil
    end
    @coordinate = CLLocationCoordinate2D.new(@params[:latitude], @params[:longitude])
  end

  def set_defaults
    @params[:title] ||= "Title"
    @params[:pin_color] ||= MKPinAnnotationColorRed
    @params[:identifier] ||= "Annotation-#{@params[:pin_color]}"
    @params[:show_callout] ||= true
    @params[:animates_drop] ||= false
  end

  def title
    @params[:title]
  end

  def subtitle
    @params[:subtitle] ||= nil
  end

  def coordinate
    @coordinate
  end

  def cllocation
    CLLocation.alloc.initWithLatitude(@params[:latitude], longitude:@params[:longitude])
  end

  def setCoordinate(new_coordinate);
    if new_coordinate.is_a? Hash
      @coordinate = CLLocationCoordinate2D.new(new_coordinate[:latitude], new_coordinate[:longitude])
    else
      @coordinate = new_coordinate
    end
  end

  # Allows for retrieving your own custom values on the annotation
  def annotation_params
    @params
  end

end
