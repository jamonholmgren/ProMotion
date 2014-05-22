class TableScreenIndexable < PM::TableScreen
  indexable

  def table_data
    %w{ Apple Google Microsoft Oracle Sun UNIX }.map do |group_name|
      {
        title: "#{group_name} Group",
        cells: [{ title: "Single cell for group #{group_name}" }]
      }
    end
  end

end

class TableScreenIndexableSearchable < TableScreenIndexable
  indexable
  searchable
end
