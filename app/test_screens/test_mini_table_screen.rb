class TestCell < PM::TableViewCell
  attr_accessor :on_reuse_fired

  def on_reuse
    self.on_reuse_fired = true
  end
end

class TestMiniTableScreen < ProMotion::TableScreen

  attr_accessor :tap_counter, :cell_was_deleted, :got_index_path

  def table_data
    [{
      cells: (0..20).map do |n|
        { title: "test#{n}", cell_class: TestCell, height: 200, cell_identifier: "test" }
      end
    }]
  end
end
