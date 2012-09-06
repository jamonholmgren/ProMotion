module ProMotion
  module ViewHelper
    def set_attributes(element, args = {})
      args.each do |k, v|
        element.send("#{k}=", v) if element.respond_to? "#{k}="
      end
      element
    end

    def frame_from_array(array)
      return CGRectMake(array[0], array[1], array[2], array[3]) if array.length = 4
      Console.log(" - frame_from_array expects an array with four elements.", withColor: Console::RED_COLOR)
      CGRectZero
    end
  end
end