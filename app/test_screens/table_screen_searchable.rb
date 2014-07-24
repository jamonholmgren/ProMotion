class TableScreenSearchable < TestTableScreen

  searchable scoped: ['North', 'South', 'Midwest', 'West', 'Other'], scoped_all: "Everything"

  attr_accessor :will_end_search_called, :will_begin_search_called

  def on_load
    super
    @subtitle ||= 0
  end

  def table_data
    @search_table_data = [{
      cells: [
        build_cell("Alabama"), # Alabama should show up in All, but not in South
        build_cell("Alaska", :other),
        build_cell("Arizona", :west),
        build_cell("Arkansas", :midwest),
        build_cell("California", :west),
        build_cell("Colorado", :midwest),
        build_cell("Connecticut", :north),
        build_cell("Delaware", :north),
        build_cell("Florida", :south),
        build_cell("Georgia", :south),
        build_cell("Hawaii", :other),
        build_cell("Idaho", :midwest),
        build_cell("Illinois", :midwest),
        build_cell("Indiana", :midwest),
        build_cell("Iowa", :midwest),
        build_cell("Kansas", :midwest),
        build_cell("Kentucky", :south),
        build_cell("Louisiana", :south),
        build_cell("Maine", :north),
        build_cell("Maryland", :north),
        build_cell("Massachusetts", :north),
        build_cell("Michigan", :midwest),
        build_cell("Minnesota", :midwest),
        build_cell("Mississippi", :south),
        build_cell("Missouri", :midwest),
        build_cell("Montana", :midwest),
        build_cell("Nebraska", :midwest),
        build_cell("Nevada", :west),
        build_cell("New Hampshire", :north),
        build_cell("New Jersey", :north),
        build_cell("New Mexico", :west),
        build_cell("New York", :north),
        build_cell("North Carolina", :south),
        build_cell("North Dakota", :midwest),
        build_cell("Ohio", :midwest),
        build_cell("Oklahoma", :midwest),
        build_cell("Oregon", :west),
        build_cell("Pennsylvania", :north),
        build_cell("Rhode Island", :north),
        build_cell("South Carolina", :south),
        build_cell("South Dakota", :midwest),
        build_cell("Tennessee", :south),
        build_cell("Texas", :south),
        build_cell("Utah", :west),
        build_cell("Vermont", :north),
        build_cell("Virginia", :south),
        build_cell("Washington", :west),
        build_cell("West Virginia", :north),
        build_cell("Wisconsin", :midwest),
        build_cell("Wyoming", :midwest)
      ]
    }]
  end

  def build_cell(title, scope = nil)
    {
      title: title,
      subtitle: @subtitle.to_s,
      action: :update_subtitle,
      scoped: scope
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
