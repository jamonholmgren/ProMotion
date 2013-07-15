class TestWebScreen < PM::WebScreen

  title "WebScreen Test"

  attr_accessor :load_started, :load_failed, :load_finished, :load_failed_error

  def load_started
    self.load_started = true
  end

  def load_finished
    self.load_finished = true
  end

  def load_failed(error)
    puts "Load Failed: #{error.localizedDescription}"
    puts error.localizedFailureReason
    self.load_failed = true
    self.load_failed_error = error
  end

end
