describe "logger functionality" do

  it "should respond to PM.logger with a logger instance" do
    PM.logger.is_a?(PM::Logger).should == true
  end
  
  it "should allow setting the log level" do
    PM.logger.level = :warn
    PM.logger.level.should == :warn
  end

end