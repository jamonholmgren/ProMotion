class MyView < UIView; end

class LoadViewScreen < PM::Screen
  def load_view
    self.view = MyView.new
  end

  def on_load
    self.view.backgroundColor = UIColor.redColor
  end
end

class MyTableView < UITableView; end

class LoadViewTableScreen < PM::Screen
  def load_view
    self.view = MyTableView.new
  end

  def on_load
    self.view.backgroundColor = UIColor.greenColor
  end

  def table_data
    []
  end
end
