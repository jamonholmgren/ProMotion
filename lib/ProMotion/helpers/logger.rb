module ProMotion
  class Logger
    attr_accessor :level
    
    NAME = "ProMotion::Logger: "
    
    COLORS = {
      default:    [ '', '' ],
      red:        [ "\e[0;31m", "\e[0m" ],
      green:      [ "\e[0;32m", "\e[0m" ],
      yellow:     [ "\e[0;33m", "\e[0m" ],
      blue:       [ "\e[0;34m", "\e[0m" ],
      purple:     [ "\e[0;35m", "\e[0m" ],
      cyan:       [ "\e[0;36m", "\e[0m" ]
    }
    
    LEVELS = {
      off:        [],
      error:      [:error],
      warn:       [:error, :warn],
      info:       [:error, :warn, :info],
      verbose:    [:error, :warn, :info, :debug, :verbose],
      debug:      [:error, :warn, :info, :debug, :verbose]
    }
    
    def level
      @level ||= :debug
    end
    
    def levels
      LEVELS[self.level] || []
    end
    
    # Usage: PM.logger.log("ERROR", "message here", :red)
    def log(label, message_text, color) 
      return if RUBYMOTION_ENV == "test"
      color = COLORS[color] || COLORS[:default]
      puts color[0] + NAME + "[#{label}] #{message_text}" + color[1]
    end

    def error(message)
      self.log('ERROR', message, :red) if self.levels.include?(:error)
    end 

    def deprecated(message)
      self.log('DEPRECATED', message, :yellow) if self.levels.include?(:warn)
    end 

    def warn(message) 
      self.log('WARN', message, :yellow) if self.levels.include?(:warn)
    end
    
    def debug(message) 
      self.log('DEBUG', message, :purple) if self.levels.include?(:debug)
    end 

    def info(message) 
      self.log('INFO', message, :green) if self.levels.include?(:info)
    end

  end
  
  module_function

  def logger
    @logger ||= Logger.new
  end

  def logger=(log)
    @logger = log
  end

end
