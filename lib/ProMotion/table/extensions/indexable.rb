module ProMotion
  module Table
    module Indexable
      def table_data_index
        return nil if @promotion_table_data.filtered || !self.class.get_indexable

        index = @promotion_table_data.sections.collect{ |section| section[:title][0] }
        index.unshift("{search}") if self.class.get_searchable
        index
      end
    end
  end
end
