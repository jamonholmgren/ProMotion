module ProMotion
  class TableScreen < TableViewController
    include ProMotion::ScreenModule
    include ProMotion::TableBuilder
    include ProMotion::Table
  end
end
