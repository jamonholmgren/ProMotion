module ProMotion
  # Instance methods
  class TableScreen < Screen
    include MotionTable::PlainTable
    include MotionTable::SearchableTable

    def view
      return self.view_controller.view
    end

    def load_view_controller
      check_table_data_method

      self.view_controller ||= TableViewController
      self.view_controller.view = self.createTableViewFromData(self.table_data)
      if self.class.get_searchable
        self.makeSearchable(contentController: self.view_controller, searchBar: self.class.get_searchable_params)
      end
    end

    def check_table_data_method
      Console.log("- table_data method needed in table view screen.", withColor: Console::RED_COLOR) unless self.respond_to?(:table_data)
    end

    def update_table_data
      self.updateTableViewData(table_data)
    end

    class << self
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
  end

  class GroupedTableScreen < TableScreen
    include MotionTable::GroupedTable
  end

  class SectionedTableScreen < TableScreen
    include MotionTable::SectionedTable
  end
end