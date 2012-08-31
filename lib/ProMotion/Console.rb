module ProMotion
  class Console
    NAME = "RubyMotion::Console"
    DEFAULT_COLOR = [ '', '' ]
    RED_COLOR = [ "\e[0;31m", "\e[0m" ] # Must be in double quotes
    GREEN_COLOR = [ "\e[0;32m", "\e[0m" ] 
    PURPLE_COLOR = [ "\e[0;35m", "\e[0m" ] 

    class << self
      def log(log, withColor:color)
        puts color[0] + NAME + log + color[1]
      end

      def log(log)
        log(log, withColor: DEFAULT_COLOR)
      end
    end
  end
end