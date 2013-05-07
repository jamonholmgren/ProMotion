module ProMotion
  module TableScreenModule
    include MotionTable::PlainTable
    include MotionTable::SearchableTable
    include MotionTable::RefreshableTable
    include ProMotion::ScreenModule

    def update_table_data
      self.update_table_view_data(table_data)
    end

    module TableClassMethods
      # Searchable
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

      # Refreshable
      def refreshable(params = {})
        @refreshable_params = params
        @refreshable = true
      end

      def get_refreshable
        @refreshable ||= false
      end

      def get_refreshable_params
        @refreshable_params ||= nil
      end

    end
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(TableClassMethods)
    end
  end
end