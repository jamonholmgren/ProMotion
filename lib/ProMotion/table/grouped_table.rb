module ProMotion
  module GroupedTable
    module GroupedTableClassMethods
      def table_style
        UITableViewStyleGrouped
      end
    end
    def self.included(base)
      base.extend(GroupedTableClassMethods)
    end
  end
end
