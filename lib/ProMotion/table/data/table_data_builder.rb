module ProMotion
  module TableDataBuilder
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
  end
end
