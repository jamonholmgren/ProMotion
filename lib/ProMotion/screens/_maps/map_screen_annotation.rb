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
    @params[:pin_color] ||= MKPinAnnotationColorRed
    @params[:identifier] ||= "Annotation-#{pin_color}"
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
      @coordinate = CLLocationCoordinate2DMake(new_coordinate[:latitude], new_coordinate[:longitude])
    else
      @coordinate = new_coordinate
    end
  end

  # Handle returning *any* properties that the user sets in the initial parameters.
  def method_missing(m, *args, &block)
    @params[m.to_sym] if @params[m.to_sym]
  end

  # Allows for retrieving your own custom values on the annotation
  def annotation_params
    @params
  end

end
