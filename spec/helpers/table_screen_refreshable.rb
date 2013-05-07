class TableScreenRefreshable < TableScreen
  attr_accessor :on_refresh_called

  refreshable

  def on_refresh
    self.on_refresh_called = true
    end_refreshing
  end

end