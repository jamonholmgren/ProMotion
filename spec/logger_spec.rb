describe "logger functionality" do

  describe "basic logger" do
    it "should respond to PM.logger with a logger instance" do
      PM.logger.is_a?(PM::Logger).should == true
    end
    
    it "should allow setting the log level" do
      PM.logger.level = :warn
      PM.logger.level.should == :warn
    end
  end

  describe "testing levels" do

    before do
      PM.logger.stub! :log {|a, b, c| "It worked" }
    end

    after do
      PM.logger.level = :debug
    end

    it "should not log if level is set to :none" do

      PM.logger.stub! :log do |label, message_text, color|
        should.flunk "should not log if logging is turned off!"
      end

      PM.logger.level = :none
      PM.logger.warn("I'm giving you a warning that you should ignore.").should == nil

    end

    it "#error should log if set to :error level or above" do

      PM.logger.level = :error
      PM.logger.error("test message").should == "It worked"

    end

    it "#deprecated should log if set to :warn level or above" do

      PM.logger.level = :warn
      PM.logger.deprecated("test message").should == "It worked"

    end
    it "#warn should log if set to :warn level or above" do

      PM.logger.level = :warn
      PM.logger.warn("test message").should == "It worked"

    end
    it "#debug should log if set to :debug level or above" do

      PM.logger.level = :debug
      PM.logger.debug("test message").should == "It worked"

    end
    it "#info should log if set to :info level or above" do

      PM.logger.level = :info
      PM.logger.info("test message").should == "It worked"

    end

  end
end
