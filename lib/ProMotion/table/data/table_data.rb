module ProMotion
  class TableData
    include ProMotion::Table::Utils

    attr_accessor :data, :filtered_data, :search_string, :original_search_string, :filtered, :table_view, :search_params

    def initialize(data, table_view, controller = nil)
      @controller = controller
      self.data = data
      self.table_view = WeakRef.new(table_view)
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
      params = index_path_to_section_index(params)
      table_section = params[:unfiltered] ? self.data[params[:section]] : self.section(params[:section])
      c = table_section[:cells].at(params[:index].to_i)
      set_data_cell_defaults c
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

    def custom_search?(params)
      return params[:with] ||
      params[:find_by] ||
      params[:search_by] ||
      params[:filter_by]
    end

    def search(search_string, params = {})
      start_searching(search_string)

      self.data.compact.each do |section|
        new_section = {}

        new_section[:cells] = section[:cells].map do |cell|
          if search_method = custom_search?(params)
            case search_method
              when Proc   then search_method.call(cell, search_string)
              when Symbol then @controller.send(search_method, cell, search_string)
            end
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

    def set_data_cell_defaults(data_cell)
      data_cell[:cell_style] ||= begin
        data_cell[:subtitle] ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault
      end
      data_cell[:cell_class] ||= PM::TableViewCell
      data_cell[:cell_identifier] ||= build_cell_identifier(data_cell)
      data_cell[:properties] ||= data_cell[:style] || data_cell[:styles]

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

  private

    def start_searching(search_string)
      self.filtered_data = []
      self.filtered = true
      self.search_string = search_string.downcase.strip
      self.original_search_string = search_string
    end
  end
end
