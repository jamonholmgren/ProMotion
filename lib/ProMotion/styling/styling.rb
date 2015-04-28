module ProMotion
  module Styling
    def set_attributes(element, args = {})
      args = get_attributes_from_symbol(args)
      ignore_keys = [:transition_style, :presentation_style]
      args.each do |k, v|
        set_attribute(element, k, v) unless ignore_keys.include?(k)
      end
      element.send(:on_styled) if element.respond_to?(:on_styled)
      element
    end

    def set_attribute(element, k, v)
      return unless element

      if !element.is_a?(CALayer) && v.is_a?(Hash) && element.respond_to?("#{k}=")
        element.send("#{k}=", v)
      elsif v.is_a?(Hash) && element.respond_to?(k)
        sub_element = element.send(k)
        set_attributes(sub_element, v) if sub_element
      elsif element.respond_to?("#{k}=")
        element.send("#{k}=", v)
      elsif v.is_a?(Array) && element.respond_to?("#{k}") && element.method("#{k}").arity == v.length
        element.send("#{k}", *v)
      elsif k.to_s.include?("_") # Snake case?
        set_attribute(element, camelize(k), v)
      else # Warn
        mp "set_attribute: #{element.inspect} does not respond to #{k}=.", force_color: :purple
        # TODO - remove now, or when fully deprecated - there will be no verbose
        # check when logger is removed
        mp "BACKTRACE", caller(0).join("\n") if PM.logger.level == :verbose
      end
      element
    end

    def content_max(view, mode = :height)
      view.subviews.map do |sub_view|
        if sub_view.isHidden
          0
        elsif mode == :height
          sub_view.frame.origin.y + sub_view.frame.size.height
        else
          sub_view.frame.origin.x + sub_view.frame.size.width
        end
      end.max.to_f
    end

    def content_height(view)
      content_max(view, :height)
    end

    def content_width(view)
      content_max(view, :width)
    end

    # iterate up the view hierarchy to find the parent element
    # of "type" containing this view
    def closest_parent(type, this_view = nil)
      this_view ||= view_or_self.superview
      while this_view != nil do
        return this_view if this_view.is_a? type
        this_view = this_view.superview
      end
      nil
    end

    def add(element, attrs = {})
      add_to view_or_self, element, attrs
    end

    def remove(elements)
      Array(elements).each(&:removeFromSuperview)
    end

    def add_to(parent_element, elements, attrs = {})
      attrs = get_attributes_from_symbol(attrs)
      Array(elements).each do |element|
        parent_element.addSubview element
        set_attributes(element, attrs) if attrs && attrs.length > 0
        element.send(:on_load) if element.respond_to?(:on_load)
      end
      elements
    end

    def view_or_self
      self.respond_to?(:view) ? self.view : self
    end

    # These three color methods are stolen from BubbleWrap.
    def rgb_color(r,g,b)
      rgba_color(r,g,b,1)
    end

    def rgba_color(r,g,b,a)
      r,g,b = [r,g,b].map { |i| i / 255.0}
      UIColor.colorWithRed(r, green: g, blue:b, alpha:a)
    end

    def hex_color(str)
      hex_color = str.gsub("#", "")
      case hex_color.size
      when 3
        colors = hex_color.scan(%r{[0-9A-Fa-f]}).map{ |el| (el * 2).to_i(16) }
      when 6
        colors = hex_color.scan(%r<[0-9A-Fa-f]{2}>).map{ |el| el.to_i(16) }
      else
        raise ArgumentError
      end

      raise ArgumentError unless colors.size == 3
      rgb_color(colors[0], colors[1], colors[2])
    end

    # Turns a snake_case string into a camelCase string.
    def camelize(str)
      str.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

  protected

    def get_attributes_from_symbol(attrs)
      return attrs if attrs.is_a?(Hash)
      mp("#{attrs} styling method is not defined", force_color: :red) unless self.respond_to?(attrs)
      new_attrs = send(attrs)
      mp("#{attrs} should return a hash", force_color: :red) unless new_attrs.is_a?(Hash)
      new_attrs
    end

    def map_resize_symbol(symbol)
      @_resize_symbols ||= {
        left:     UIViewAutoresizingFlexibleLeftMargin,
        right:    UIViewAutoresizingFlexibleRightMargin,
        top:      UIViewAutoresizingFlexibleTopMargin,
        bottom:   UIViewAutoresizingFlexibleBottomMargin,
        width:    UIViewAutoresizingFlexibleWidth,
        height:   UIViewAutoresizingFlexibleHeight
      }
      @_resize_symbols[symbol] || symbol
    end

  end
end
