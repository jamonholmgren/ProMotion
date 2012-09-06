module ProMotion
  module ViewHelper
    def set_attributes(element, args = {})
      args.each do |k, v|
        element.send("#{k}=", v) if element.respond_to? "#{k}="
      end
      element
    end
  end
end