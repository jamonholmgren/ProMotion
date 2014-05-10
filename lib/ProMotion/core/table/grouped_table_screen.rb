module ProMotion
  # @requires class:TableViewController
  class GroupedTableScreen < TableViewController
    # @requires module:ScreenModule
    include ProMotion::ScreenModule
    # @requires module:Table
    include ProMotion::Table
    # @requires module:GroupedTable
    include ProMotion::GroupedTable
  end
end
