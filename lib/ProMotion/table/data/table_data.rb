module ProMotion
  class TableData
    attr_accessor :data, :filtered_data, :search_string, :original_search_string, :filtered, :table_view

    def initialize(data, table_view)
      self.data = data
      self.table_view = table_view
    end

    def section(index)
      s = sections.at(index)
      s || { title: nil, cells: [] }
    end

    def sections
      self.filtered ? self.filtered_data : self.data
    end

    def section_length(index)
      section(index)[:cells].length
    end

    def cell(params={})
      if params[:index_path]
        params[:section] = params[:index_path].section
        params[:index] = params[:index_path].row
      end

      table_section = self.section(params[:section])
      c = table_section[:cells].at(params[:index].to_i)
      set_data_cell_defaults c
    end

    def delete_cell(params={})
      if params[:index_path]
        params[:section] = params[:index_path].section
        params[:index] = params[:index_path].row
      end

      table_section = self.section(params[:section])
      table_section[:cells].delete_at(params[:index].to_i)
    end

    def search(search_string)
      self.filtered_data = []
      self.filtered = true

      self.original_search_string = search_string
      self.search_string = search_string.downcase.strip

      self.data.compact.each do |section|
        new_section = {}
        new_section[:cells] = []

        new_section[:cells] = section[:cells].map do |cell|
          cell[:searchable] != false && "#{cell[:title]}\n#{cell[:search_text]}".downcase.strip.include?(self.search_string) ? cell : nil
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

    def set_data_cell_defaults(data_cell)
      data_cell[:cell_style] ||= UITableViewCellStyleDefault
      data_cell[:cell_class] ||= PM::TableViewCell
      data_cell[:cell_identifier] ||= build_cell_identifier(data_cell)

      data_cell[:accessory] = {
        view: data_cell[:accessory],
        value: data_cell[:accessory_value],
        action: data_cell[:accessory_action],
        arguments: data_cell[:accessory_arguments]
      } unless data_cell[:accessory].nil? || data_cell[:accessory].is_a?(Hash)

      data_cell
    end

    def build_cell_identifier(data_cell)
      ident = "#{data_cell[:cell_class].to_s}"
      ident << "-#{data_cell[:stylename].to_s}" if data_cell[:stylename] # For Teacup
      ident << "-accessory" if data_cell[:accessory]
      ident << "-subtitle" if data_cell[:subtitle]
      ident << "-remoteimage" if data_cell[:remote_image]
      ident << "-image" if data_cell[:image]
      ident
    end

  end
end
