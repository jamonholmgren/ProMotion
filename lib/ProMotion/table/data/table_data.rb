module ProMotion
  class TableData
    attr_accessor :data, :filtered_data, :filtered, :table_view

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
      table_section[:cells].at(params[:index].to_i)
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

      search_string = search_string.downcase.strip

      self.data.each do |section|
        new_section = {}
        new_section[:cells] = []

        new_section[:cells] = section[:cells].map do |cell|
          cell[:searchable] != false && "#{cell[:title]}\n#{cell[:search_text]}".downcase.strip.include?(search_string) ? cell : nil
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
    end

    def table_view_cell(params={})
      if params[:index_path]
        params[:section] = params[:index_path].section
        params[:index] = params[:index_path].row
      end

      data_cell = self.cell(section: params[:section], index: params[:index])
      return UITableViewCell.alloc.init unless data_cell # No data?

      data_cell = self.set_data_cell_defaults(data_cell)

      table_cell = self.create_table_cell(data_cell)

      table_cell
    end

    def set_data_cell_defaults(data_cell)
      data_cell[:cell_style] ||= UITableViewCellStyleDefault
      data_cell[:cell_identifier] ||= build_cell_identifier(data_cell)
      data_cell[:cell_class] ||= ProMotion::TableViewCell
      data_cell
    end

    def create_table_cell(data_cell)
      table_cell = table_view.dequeueReusableCellWithIdentifier(data_cell[:cell_identifier])

      unless table_cell
        table_cell = data_cell[:cell_class].alloc.initWithStyle(data_cell[:cell_style], reuseIdentifier:data_cell[:cell_identifier])
        table_cell.extend ProMotion::TableViewCellModule unless table_cell.is_a?(ProMotion::TableViewCellModule)
        table_cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
      end

      table_cell.setup(data_cell)

      table_cell
    end

    def build_cell_identifier(data_cell)
      ident = "Cell"
      unless data_cell[:accessory].nil?
        if data_cell[:accessory][:view] == :switch
          ident << "-switch"
        elsif !data_cell[:accessory][:view].nil?
          ident << "-accessory"
        end
      end
      ident << "-subtitle" if data_cell[:subtitle]
      ident << "-remoteimage" if data_cell[:remote_image]
      ident << "-image" if data_cell[:image]
      ident
    end

  end
end
