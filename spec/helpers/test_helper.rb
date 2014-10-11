class TestHelper
  def self.ios6
    UIDevice.currentDevice.systemVersion.to_f >= 6.0 &&
    UIDevice.currentDevice.systemVersion.to_f < 7.0
  end

  def self.ios7
    UIDevice.currentDevice.systemVersion.to_f >= 7.0 &&
    UIDevice.currentDevice.systemVersion.to_f < 8.0
  end

  def self.ios8
    UIDevice.currentDevice.systemVersion.to_f >= 8.0 &&
    UIDevice.currentDevice.systemVersion.to_f < 9.0
  end
end

def silence_warnings(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  begin
    result = block.call
  ensure
    $VERBOSE = warn_level
  end
  result
end

silence_warnings do
  module Bacon
    if ENV['filter']
      $stderr.puts "Filtering specs that match: #{ENV['filter']}"
      RestrictName = Regexp.new(ENV['filter'])
    end

    if ENV['filter_context']
      $stderr.puts "Filtering contexts that match: #{ENV['filter_context']}"
      RestrictContext = Regexp.new(ENV['filter_context'])
    end

    Backtraces = false if ENV['hide_backtraces']
  end
end
