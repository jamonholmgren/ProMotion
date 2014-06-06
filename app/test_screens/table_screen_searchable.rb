class TableScreenSearchable < TestTableScreen

  searchable

  attr_accessor :will_end_search_called, :will_begin_search_called

  def on_load
    super
    @subtitle ||= 0
  end

  def table_data
    @search_table_data = [{
      cells: [
        build_cell("Alabama"),
        build_cell("Alaska"),
        build_cell("Arizona"),
        build_cell("Arkansas"),
        build_cell("California"),
        build_cell("Colorado"),
        build_cell("Connecticut"),
        build_cell("Delaware"),
        build_cell("Florida"),
        build_cell("Georgia"),
        build_cell("Hawaii"),
        build_cell("Idaho"),
        build_cell("Illinois"),
        build_cell("Indiana"),
        build_cell("Iowa"),
        build_cell("Kansas"),
        build_cell("Kentucky"),
        build_cell("Louisiana"),
        build_cell("Maine"),
        build_cell("Maryland"),
        build_cell("Massachusetts"),
        build_cell("Michigan"),
        build_cell("Minnesota"),
        build_cell("Mississippi"),
        build_cell("Missouri"),
        build_cell("Montana"),
        build_cell("Nebraska"),
        build_cell("Nevada"),
        build_cell("New Hampshire"),
        build_cell("New Jersey"),
        build_cell("New Mexico"),
        build_cell("New York"),
        build_cell("North Carolina"),
        build_cell("North Dakota"),
        build_cell("Ohio"),
        build_cell("Oklahoma"),
        build_cell("Oregon"),
        build_cell("Pennsylvania"),
        build_cell("Rhode Island"),
        build_cell("South Carolina"),
        build_cell("South Dakota"),
        build_cell("Tennessee"),
        build_cell("Texas"),
        build_cell("Utah"),
        build_cell("Vermont"),
        build_cell("Virginia"),
        build_cell("Washington"),
        build_cell("West Virginia"),
        build_cell("Wisconsin"),
        build_cell("Wyoming")
      ]
    }]
  end

  def build_cell(title)
    {
      title: title,
      subtitle: @subtitle.to_s,
      action: :update_subtitle
    }
  end

  def update_subtitle
    @subtitle = @subtitle + 1
    update_table_data
  end

  def will_begin_search
    self.will_begin_search_called = true
  end

  def will_end_search
    self.will_end_search_called = true
  end

end
