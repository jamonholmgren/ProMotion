module ProMotion
  module ViewHelper
    def set_attributes(element, args = {})
      args.each do |k, v|
        if v.is_a? Hash
          v.each do |k2, v2|
            sub_element = element.send("#{k}")
            sub_element.send("#{k2}=", v2) if sub_element.respond_to?("#{k2}=")
          end
        elsif v.is_a? Array
          element.send("#{k}", *v) if element.respond_to?("#{k}")
        else
          element.send("#{k}=", v) if element.respond_to?("#{k}=")
        end
      end
      element
    end

    def frame_from_array(array)
      return CGRectMake(array[0], array[1], array[2], array[3]) if array.length == 4
      Console.log(" - frame_from_array expects an array with four elements.", withColor: Console::RED_COLOR)
      CGRectZero
    end
  end
end