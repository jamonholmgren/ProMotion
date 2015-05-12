class TestCell < PM::TableViewCell
  attr_accessor :on_reuse_fired, :prepare_for_reuse_fired, :on_reuse_time, :prepare_for_reuse_time

  def on_reuse
    self.on_reuse_fired = true
    self.on_reuse_time = Time.now
  end

  def prepare_for_reuse
    self.prepare_for_reuse_fired = true
    self.prepare_for_reuse_time = Time.now
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
