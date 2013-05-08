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
        puts color[0] + NAME + log + color[1]
      end

      def log(log, withColor:color)
        return if RUBYMOTION_ENV == "test"
        warn "[DEPRECATION] `log(log, withColor:color)` is deprecated. Use `log(log, with_color:color)`"
        self.log(log, with_color:color)
      end

      def log(log)
        return if RUBYMOTION_ENV == "test"
        log(log, with_color: DEFAULT_COLOR)
      end
    end
  end
end