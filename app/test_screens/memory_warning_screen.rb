class MemoryWarningScreenSelfImplemented < ProMotion::Screen
  attr_accessor :memory_warning_from_uikit

  def didReceiveMemoryWarning
    @memory_warning_from_uikit = true
    super
  end
end

class MemoryWarningScreen < ProMotion::Screen
  attr_accessor :memory_warning_from_pm

  def on_memory_warning
    @memory_warning_from_pm = true
  end
end

class MemoryWarningSuperScreen < ProMotion::Screen
  def didReceiveMemoryWarning
    @memory_warning_from_super = true
    super
  end

  def memory_warning_from_super
    @memory_warning_from_super
  end
end

class MemoryWarningNotSoSuperScreen < MemoryWarningSuperScreen
  def on_memory_warning
    # This should call super without me putting it here.
  end
end
