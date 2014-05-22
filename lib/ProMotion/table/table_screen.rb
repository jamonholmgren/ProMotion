module ProMotion
  # @requires class:TableViewController
  class TableScreen < TableViewController
    # @requires module:ScreenModule
    include ProMotion::ScreenModule
    # @requires module:Table
    include ProMotion::Table
  end
end
