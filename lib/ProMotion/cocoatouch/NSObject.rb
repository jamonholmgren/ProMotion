# Should we do this? Maybe identify what cocoa touch classes need it and monkeypatch
# those instead?
# class NSObject
#   def method_missing(meth, *args)
#     obj_c_meth = meth.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
#     if respond_to?(obj_c_meth)
#       send obj_c_meth, *args
#     else
#       raise NoMethodError.new(meth.to_s) 
#     end
#   end
# end

# # In the REPL:
# v = UIView.new # => #<UIView:0xaa45260>
# v.background_color = UIColor.white_color # => #<UICachedDeviceWhiteColor:0xaa41180>
# v.backgroundColor => #<UICachedDeviceWhiteColor:0x967c2e0>
# v.asdf # => #<NoMethodError: asdf>

