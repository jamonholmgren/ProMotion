module ProMotion
  module Conversions
    
    # For converting, for example, from :contacts to UITabBarSystemItemContacts
    # Unfortunately, this only works if the symbol is defined in your code.
    # So, for now, we'll have to do it manually.
    def convert_symbol(symbol, prefix)
      Object.const_get("#{prefix}#{camel_case symbol}")
    end
    
    def objective_c_method_name(str)
      str.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end
    
    def camel_case(str)
      str.split('_').map(&:capitalize).join
    end
    
  end
end
