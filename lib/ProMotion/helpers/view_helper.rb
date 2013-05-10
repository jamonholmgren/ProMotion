module ProMotion
  module ViewHelper
    def set_attributes(element, args = {})
      args.each { |k, v| set_attribute(element, k, v) }
      element
    end

    def set_attribute(element, k, v)
      if v.is_a?(Hash) && element.respond_to?(k)
        sub_element = element.send(k)
        set_attributes sub_element, v
      elsif v.is_a?(Array) && element.respond_to?("#{k}")
        element.send("#{k}", *v)
      elsif element.respond_to?("#{k}=")
        element.send("#{k}=", v)
      else
        # Doesn't respond. Check if snake case.
        if k.to_s.include?("_")
          set_attribute(element, objective_c_method_name(k), v)
        end
      end
      element
    end

    def objective_c_method_name(meth)
      meth.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

    def set_easy_attributes(parent, element, args={})
      attributes = {}

      if args[:resize]
        attributes[:autoresizingMask]  = UIViewAutoresizingNone
        attributes[:autoresizingMask] |= UIViewAutoresizingFlexibleLeftMargin   if args[:resize].include?(:left)
        attributes[:autoresizingMask] |= UIViewAutoresizingFlexibleRightMargin  if args[:resize].include?(:right)
        attributes[:autoresizingMask] |= UIViewAutoresizingFlexibleTopMargin    if args[:resize].include?(:top)
        attributes[:autoresizingMask] |= UIViewAutoresizingFlexibleBottomMargin if args[:resize].include?(:bottom)
        attributes[:autoresizingMask] |= UIViewAutoresizingFlexibleWidth        if args[:resize].include?(:width)
        attributes[:autoresizingMask] |= UIViewAutoresizingFlexibleHeight       if args[:resize].include?(:height)
      end

      if [:left, :top, :width, :height].select{ |a| args[a] && args[a] != :auto }.length == 4
        attributes[:frame] = CGRectMake(args[:left], args[:top], args[:width], args[:height])
      end

      set_attributes element, attributes
      element
    end

    def frame_from_array(array)
      PM.logger.deprecated "`frame_from_array` is deprecated and will be removed. Use RubyMotion's built-in [[x, y], [width, height]]."
      return CGRectMake(array[0], array[1], array[2], array[3]) if array.length == 4
      PM.logger.error "frame_from_array expects an array with four elements: [x, y, width, height]"
      CGRectZero.dup
    end

    def content_height(view)
      height = 0
      view.subviews.each do |sub_view|
        next if sub_view.isHidden
        y = sub_view.frame.origin.y
        h = sub_view.frame.size.height
        if (y + h) > height
          height = y + h
        end
      end
      height
    end

  end
end