module ProMotion
  module CollectionDataBuilder
    def set_data_cell_defaults(data_cell)
      data_cell[:cell_identifier] ||= PM::CollectionViewCell::KIdentifier
      data_cell[:properties]      ||= data_cell[:style] || data_cell[:styles]

      data_cell[:accessory]       = {
        view:      data_cell[:accessory],
        value:     data_cell[:accessory_value],
        action:    data_cell[:accessory_action],
        arguments: data_cell[:accessory_arguments]
      } unless data_cell[:accessory].nil? || data_cell[:accessory].is_a?(Hash)

      data_cell
    end

  end
end
