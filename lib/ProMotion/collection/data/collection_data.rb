module ProMotion
  class CollectionData
    include ProMotion::Table::Utils
    include ProMotion::CollectionDataBuilder

    attr_accessor :data, :collection_view

    def initialize(data, collection_view)
      self.data            = data
      self.collection_view = WeakRef.new(collection_view)
    end

    def section(index)
      sections.at(index) || []
    end

    def sections
      self.data
    end

    def section_length(index)
      section(index).length
    end

    def cell(params={})
      params  = index_path_to_section_index(params)
      section = self.data[params[:section]]
      c       = section.at(params[:index].to_i)
      set_data_cell_defaults(c)
    end
  end
end
