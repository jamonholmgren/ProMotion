class TestHelper
  def self.ios_version
    UIDevice.currentDevice.systemVersion.to_f
  end

  def self.ios6
    ios_version >= 6.0 && ios_version < 7.0
  end

  def self.ios7
    ios_version >= 7.0 && ios_version < 8.0
  end

  def self.ios8
    ios_version >= 8.0 && ios_version < 9.0
  end

  def self.gte_ios8
    ios_version >= 8.0
  end

  def self.lt_ios11
    ios_version < 11.0
  end

  def self.gte_ios11
    ios_version >= 11.0
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
