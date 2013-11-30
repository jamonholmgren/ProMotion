class TestHelper
  def self.ios7
    UIDevice.currentDevice.systemVersion.to_f >= 7.0
  end
end
