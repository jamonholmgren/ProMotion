class TestWebScreen < PM::WebScreen

  title "WebScreen Test"

  # accesor for wait_change method which is testing helper
  attr_accessor :is_nav_started, :is_nav_finished, :is_nav_failed, :nav_failed_error

  def on_init
    @on_init_available = true
  end

  def on_init_available?
    @on_init_available
  end

  def content
    nil
  end

  # implementation of PM::WebScreen's hook
  def navigation_started(nav)
    self.is_nav_started = true
  end

  def navigation_finished(nav)
    self.is_nav_finished = true
  end

  def navigation_failed(nav, error)
    puts "Load Failed: #{error.localizedDescription}"
    puts error.localizedFailureReason
    self.is_nav_failed = true
    self.nav_failed_error = error
  end
end
