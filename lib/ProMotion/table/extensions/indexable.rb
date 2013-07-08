module ProMotion
  module Table
    module Indexable
      def make_indexable(params={})
        @pm_indexable = true
      end

      def index_from_section_titles
        @promotion_table_data.filtered ? nil : @promotion_table_data.sections.collect{ |section| section[:title][0] }
      end
    end
  end
end
