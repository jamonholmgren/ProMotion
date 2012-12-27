module ProMotion
  module TableScreenModule
    include ProMotion::ScreenModule
    include MotionTable::PlainTable
    include MotionTable::SearchableTable

    def update_table_data
      self.update_table_view_data(table_data)
    end

    module TableClassMethods
      def searchable(params={})
        @searchable_params = params
        @searchable = true
      end

      def get_searchable_params
        @searchable_params ||= nil
      end

      def get_searchable
        @searchable ||= false
      end
    end
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(TableClassMethods)
    end
  end
end