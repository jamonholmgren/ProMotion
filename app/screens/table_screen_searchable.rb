class TableScreenSearchable < TestTableScreen

  searchable

  attr_accessor :will_end_search_called, :will_begin_search_called

  STATES = [
    "Alabama",
    "Alaska",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "Florida",
    "Georgia",
    "Hawaii",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississippi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming"
  ].freeze

  def on_load
    super
    @subtitle ||= 0
  end

  def table_data
    @search_table_data = [{
      cells: state_cells
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

  def state_cells
    STATES.map{ |state| build_cell(state) }
  end

end

class TableScreenStabbySearchable < TableScreenSearchable
  searchable with: -> (cell, search_string) {
    result = true
    search_string.split(/\s+/).each {|term|
      result &&= cell[:properties][:searched_title].downcase.strip.include?(term.downcase.strip)
    }
    return result
  }

  def build_cell(title)
    {
      title: title,
      subtitle: @subtitle.to_s,
      action: :update_subtitle,
      properties: {
        searched_title: "#{title} - stabby"
      }
    }
  end
end

class TableScreenSymbolSearchable < TableScreenSearchable
  searchable with: :custom_search

  def custom_search(cell, search_string)
    result = true
    search_string.split(/\s+/).all? {|term|
      cell[:properties][:searched_title].downcase.strip.include?(term.downcase.strip)
    }
  end

  def build_cell(title)
    {
      title: title,
      subtitle: @subtitle.to_s,
      action: :update_subtitle,
      properties: {
        searched_title: "#{title} - symbol"
      }
    }
  end
end

class TableScreenSymbolSearchableNoResults < TableScreenSearchable
  searchable no_results: "Nada!"
end
