class TableScreenSearchable < TestTableScreen

  searchable

  attr_accessor :will_end_search_called, :will_begin_search_called

  def table_data
    @search_table_data ||= [{
      cells: [
        { title: "Alabama" },
        { title: "Alaska" },
        { title: "Arizona" },
        { title: "Arkansas" },
        { title: "California" },
        { title: "Colorado" },
        { title: "Connecticut" },
        { title: "Delaware" },
        { title: "Florida" },
        { title: "Georgia" },
        { title: "Hawaii" },
        { title: "Idaho" },
        { title: "Illinois" },
        { title: "Indiana" },
        { title: "Iowa" },
        { title: "Kansas" },
        { title: "Kentucky" },
        { title: "Louisiana" },
        { title: "Maine" },
        { title: "Maryland" },
        { title: "Massachusetts" },
        { title: "Michigan" },
        { title: "Minnesota" },
        { title: "Mississippi" },
        { title: "Missouri" },
        { title: "Montana" },
        { title: "Nebraska" },
        { title: "Nevada" },
        { title: "New Hampshire" },
        { title: "New Jersey" },
        { title: "New Mexico" },
        { title: "New York" },
        { title: "North Carolina" },
        { title: "North Dakota" },
        { title: "Ohio" },
        { title: "Oklahoma" },
        { title: "Oregon" },
        { title: "Pennsylvania" },
        { title: "Rhode Island" },
        { title: "South Carolina" },
        { title: "South Dakota" },
        { title: "Tennessee" },
        { title: "Texas" },
        { title: "Utah" },
        { title: "Vermont" },
        { title: "Virginia" },
        { title: "Washington" },
        { title: "West Virginia" },
        { title: "Wisconsin" },
        { title: "Wyoming" }
      ]
    }]
  end

  def will_begin_search
    self.will_begin_search_called = true
  end

  def will_end_search
    self.will_end_search_called = true
  end

end
