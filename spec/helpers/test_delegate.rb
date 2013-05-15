class TestDelegate < ProMotion::Delegate
  def on_load(app, options)
  end

  # Hack to make RM 2.0 work.
  # Ref: http://hipbyte.myjetbrains.com/youtrack/issue/RM-136
  def dealloc
  end
end
