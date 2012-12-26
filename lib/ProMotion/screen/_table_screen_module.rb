module ProMotion
  module TableScreenModule
    include ProMotion::ScreenModule
    include MotionTable::PlainTable
    include MotionTable::SearchableTable

    def on_init
      check_table_data_method

      self.view = self.create_table_view_from_data(self.table_data)
      if self.class.get_searchable
        self.make_searchable(content_controller: self, search_bar: self.class.get_searchable_params)
      end
    end

    def check_table_data_method
      Console.log("- table_data method needed in table view screen.", with_color: Console::RED_COLOR) unless self.respond_to?(:table_data)
    end

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