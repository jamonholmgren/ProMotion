class BasicScreen < PM::Screen
  title "Basic"

  attr_reader :animation_ts

  def will_appear
    @will_appear_ts = NSDate.date
  end
  
  def on_appear
    @on_appear_ts = NSDate.date
    @animation_ts = @on_appear_ts - @will_appear_ts
  end

end
