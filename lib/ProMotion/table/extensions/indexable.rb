module ProMotion
  module Table
    module Indexable
      def table_data_index
        index = @promotion_table_data.filtered ? nil : @promotion_table_data.sections.collect{ |section| section[:title][0] }
        index.unshift("{search}") if self.class.get_searchable
        index
      end
    end
  end
end
