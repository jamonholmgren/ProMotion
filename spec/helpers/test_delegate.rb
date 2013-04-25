class TestDelegate < ProMotion::Delegate
  def on_load(app, options)
    return false
  end
end