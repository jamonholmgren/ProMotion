module ProMotion
  class TableData
    include ProMotion::Table::Utils
    include ProMotion::TableDataBuilder

    attr_accessor :data, :filtered_data, :search_string, :original_search_string, :filtered, :table_view, :search_params

    def initialize(data, table_view, search_action = nil)
      @search_action ||= search_action

      if data.include?(nil)
        mp("Warning: You have a `nil` section in your table_data method.", force_color: :yellow)
      end

      self.data = data.compact.each_with_index.map do |section,index|
        if section[:cells].include?(nil)
          mp("Warning: You have a `nil` cell in table section #{index}.", force_color: :yellow)
          section[:cells].compact!
        end
        section
      end
      self.table_view = WeakRef.new(table_view)
    end

    def section(index)
      sections.at(index) || { cells: [] }
    end

    def sections
      self.filtered ? self.filtered_data : self.data
    end

    def section_length(index)
      section(index)[:cells].length
    end

    def cell(params={})
      params = index_path_to_section_index(params)
      table_section = params[:unfiltered] ? self.data[params[:section]] : self.section(params[:section])
      c = table_section[:cells].at(params[:index].to_i)
      set_data_cell_defaults(c)
    end

    def delete_cell(params={})
      params = index_path_to_section_index(params)
      table_section = self.section(params[:section])
      table_section[:cells].delete_at(params[:index].to_i)
    end

    def move_cell(from, to)
      section(to.section)[:cells].insert(to.row, section(from.section)[:cells].delete_at(from.row))
    end

    def default_search(cell, search_string)
      cell[:searchable] != false && "#{cell[:title]}\n#{cell[:search_text]}".downcase.strip.include?(search_string.downcase.strip)
    end

    def search(search_string)
      start_searching(search_string)

      self.data.compact.each do |section|
        new_section = {}

        new_section[:cells] = section[:cells].map do |cell|
          if @search_action
            @search_action.call(cell, search_string)
          else
            self.default_search(cell, search_string)
          end ? cell : nil
        end.compact

        if new_section[:cells] && new_section[:cells].length > 0
          new_section[:title] = section[:title]
          self.filtered_data << new_section
        end
      end

      self.filtered_data
    end

    def stop_searching
      self.filtered_data = []
      self.filtered = false
      self.search_string = false
      self.original_search_string = false
    end

  private

    def start_searching(search_string)
      self.filtered_data = []
      self.filtered = true
      self.search_string = search_string.downcase.strip
      self.original_search_string = search_string
    end
  end
end
