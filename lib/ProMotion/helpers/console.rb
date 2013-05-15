module ProMotion
  class Console
    NAME = "RubyMotion::Console: "
    DEFAULT_COLOR = [ '', '' ]
    RED_COLOR = [ "\e[0;31m", "\e[0m" ] # Must be in double quotes
    GREEN_COLOR = [ "\e[0;32m", "\e[0m" ]
    PURPLE_COLOR = [ "\e[0;35m", "\e[0m" ]

    class << self
      def log(log, with_color:color)
        return if RUBYMOTION_ENV == "test"
        PM.logger.deprecated "ProMotion::Console.log is deprecated. Use PM.logger (see README)"
        puts color[0] + NAME + log + color[1]
      end

      def log(log, withColor:color)
        return if RUBYMOTION_ENV == "test"
        PM.logger.deprecated "ProMotion::Console.log is deprecated. Use PM.logger (see README)"
        self.log(log, with_color:color)
      end

      def log(log)
        return if RUBYMOTION_ENV == "test"
        PM.logger.deprecated "ProMotion::Console.log is deprecated. Use PM.logger (see README)"
        log(log, with_color: DEFAULT_COLOR)
      end
    end
  end
end